%code requires {

	#include "node.h"
	#include "functions.h"
	#include "identifiers.h"
	#include "tokens.h"


}

%{
	//C declarations..
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "defines.h"
	#include "identifiers.h"
	#include "typechecking.h"

	#include "functions.h"
	//need these function from flex. 
	extern int yylex();
	extern int yyparse();
	//this is in order to produce a better error message. 
	extern FILE *yyin;
	extern define_array def_array;
	extern char* currName;
	extern char* yytext;
	extern int debug;
	extern int yylineno;

	//prototype
	void yyerror (char const *s);
	
	
	//this is for declarations. 
	id_list ids;

	//for funciton
	enum types returnType;
	
	int empty; //if brackets are empty ornot

	
%}

%union{
	node n;
	function f;
	identifier id;
	enum types type;
}



// all remaining tokens....
%token <type> TYPE
%token FOR
%token WHILE
%token DO
%token IF
%left NOTELSE //pseudo token. 
%left ELSE
%token BREAK
%token CONTINUE
%token RETURN
%token <id> IDENT
%token <n> INTCONST
%token <n> REALCONST
%token <n> STRCONST
%token <n> CHARCONST

%token <n> LBRACE RBRACE
%token <n> SEMI


//we set priority and the associativity left to right or right to left..
%left COMMA
%right ASSIGN
%right QUEST COLON QUESTCOLON //psuedo token for ternary expression (expr ? expr : expr)
%left DPIPE
%left DAMP
%left PIPE
%left AMP 
%left EQUALS NEQUAL
%left GT GE LT LE
%left PLUS MINUS 
%left STAR SLASH MOD 
%right BANG TILDE DECR INCR  UAMP UMINUS PARTYPE //pseudo token for casting ((type) )
%left LPAR RPAR LBRACKET RBRACKET 


%type <f> functionprototype functiondefinition functiondeclaration
%type <id> variabledeclaration declaration
%type <id> formalparameter
%type <n> expression constant binaryop unaryop ternaryexpr lvalue optionbrack
%type <type> incrdecr
//This are the values that come from lexer..


/**NEEDS : 
 * Print result of expression at file line etc. 
 * type mismatch checks
 * functions calls have correct parameters
 * return statement have correct type
 * undeclared variable and functions. 
 * ---> best effort. 
 * */
 /**
 1)declaration of variable
 2) declaration of functions
 3) check for return type of functions
 4) check for functions call
 5) check for undeclared var/func
 6) print res of expression
 
 */
%start program 

%% 
//Grammar goes here..
//The general part 
program 	: sentences 
			; 
sentences 	: sentence sentences 
			| sentence	
			; 
sentence 	: variabledeclaration 
			| functionprototype 
			| functiondefinition 
			; 

//about variable declaration : THIS IS OK (no conflict)
variabledeclaration : TYPE listidentifiers SEMI 	{/*create a list of identifiers of type $1 and add them to typechecking*/
														for(int i = 0; i < ids.size;i++){
															identifier id = ids.ids[i];
															id.type += $1;//adjust the type. 
															add_identifier_typechecking(&id);
														}
														
														//clear the ids. 
														//delete_id_list(&ids);
														ids.size = 0;
													} ; 
listidentifiers : declaration COMMA listidentifiers  {if(debug){printf("Adding identifier %s to the list\n",$1.name);}add_id(&ids,&$1);}
				| declaration 			{if(debug){printf("Adding identifier %s to the list\n",$1.name);}add_id(&ids,&$1);}
				; 
declaration : IDENT LBRACKET INTCONST RBRACKET {ident_decl(&$$,$1.name,$1.lineDecl,currName,FLOAT);/*create an ident with a base type FLOAT and then we add 1 if char , 2 if int 3 if float -- makes arr*/}
			| IDENT	{ident_decl(&$$,$1.name,$1.lineDecl,currName,0);}/*create an ident with no base type*/
			; 

//about function prototypes : THIS IS OK ( no conflict ) 
functionprototype : functiondeclaration SEMI  {exit_function(&$1,$1.returnType);add_function_typechecking(&$1);/*add the function prototype to list of function of typecheck */} ; 
functiondeclaration : TYPE IDENT LPAR formallistparameters RPAR {create_function(&$$,ids.ids,ids.size,$2.name,yylineno,currName);
																add_return_type(&$$,$1);
																enter_function(&$$);/* create a function with param $4 and store it in funcdecl*/}
					| TYPE IDENT LPAR RPAR				{create_function(&$$,NULL,0,$2.name,yylineno,currName);
														 add_return_type(&$$,$1);
														 enter_function(&$$);/* createa a fucntion with no param store it in functiondeclaration*/}
		
					;
//we can use ids also here since they will / should not be a case where we mix those two.  
formallistparameters 	: formalparameter COMMA formallistparameters {add_id(&ids,&$1);/* add the formal param to a list */}
						| formalparameter {add_id(&ids,&$1);/* add the formal param to the list above and store it in $$*/}
						;
//it is of type ident. 
formalparameter : TYPE IDENT 		{ident_decl(&$$,$2.name,yylineno,currName,$1);}
				| TYPE IDENT LBRACKET RBRACKET {ident_decl(&$$,$2.name,yylineno,currName,$1+3);}
				; 

//about function definitions.
functiondefinition 	: functiondeclaration LBRACE body RBRACE {/*at this point we are done with the function. 
								  we need to check if the return type matches. */exit_function(&$1,returnType);	returnType = NA;	 }
					| functiondeclaration LBRACE RBRACE	{fprintf(stderr, "Error Type Checking : a function needs to return something\n");/*should be an error since we want something to be returned. */}
					; 
body 	: declorstat body {/*nothing*/}
		| declorstat {/*nothing*/}
		; 
declorstat 	: variabledeclaration {/*nothing */}
			| statement {/*nothing*/}
			| statementblock {/*nothing*/}
			; 
statementblock 	: LBRACE liststatement RBRACE {/*nothing*/}
				| LBRACE RBRACE {/*nothing*/}
				; 
liststatement 	: statement liststatement {/*nothing*/}
				| statement {/*nothing*/}
				; 

//about statements...

statement 	: 	SEMI
			| keywords SEMI {/*nothing*/}
			| RETURN expression SEMI {returnType = $2.type;/*Maybe unallow further statements ???*/}
			| expression SEMI {print_expression(&$1,currName,yylineno);}
			| ifstatement {/*nothing*/}
			| forstatement {/*nothing*/}
			| whilestatement {/*nothing*/}
			| dowhilestatement {/*nothing*/}
			; 
keywords	: BREAK 
			| CONTINUE
			; 
//more specifics on statements 

ifstatement : IF LPAR expression RPAR statementorblock ELSE statementorblock 
			| IF LPAR expression RPAR statementorblock %prec NOTELSE
			;
statementorblock 	: statement 
					| statementblock 
					; 

forstatement : FOR LPAR optionalexpression SEMI optionalexpression SEMI optionalexpression RPAR statementorblock ; 
optionalexpression 	: expression  {/*TODO show th eline in the std output*/}
					| %empty 
					;
whilepart : WHILE LPAR expression RPAR  {/*nothing*/};
whilestatement : whilepart statementorblock ; 
dowhilestatement : DO statementorblock whilepart SEMI ; 

lvalue : IDENT optionbrack  {if((!empty) && $1.type < 3){
								fprintf(stderr, "Error type checking : using array accessing on a primitive type identifier %s , line %d file %s\n",$1.name,yylineno,currName);
								return 0;
							}
								//no mismatch 
								if(empty){
										//if we have no brackets. 
										create_node(&$$,$1.type);
										
										set_attribute(&$$,&$1,sizeof(identifier));
								}else{
									//we have brackets. 
									create_node(&$$,$1.type-3);
									set_right(&$$,&$2);
									set_attribute(&$$,&$1,sizeof(identifier));
								}
							}
		;
optionbrack : LBRACKET expression RBRACKET 	{empty = 0; $$ = $2; /*nothing */}
			| %empty						{empty = 1;}
			;	
expression 	: constant	{$$ = $1;/*set the node $$ as the value of $1*/}
			| IDENT {int err = find_identifier($1.name,$1.type);
					if(err == 0){
						create_node(&$$,$1.type);
						set_attribute(&$$,&$1,sizeof(node));
					}else if(err == -1){
						fprintf(stderr, "Error typechecking : undeclared identifier line %d file %s name of identifier %s\n",yylineno,currName, $1.name);
					}else if(err == -2){
						fprintf(stderr, "Error typechecking : mismatch of type. Type is %s. line %d file %s name of identifier %s\n",typeTranslation[$1.type],yylineno,currName,$1.name); 
					}
					}
			| AMP IDENT %prec UAMP {int err = find_identifier($2.name,$2.type);
									if(err==0){
										$$.type = $2.type-3;
										set_attribute(&$$,&$2,sizeof(identifier));
										//no left. 
									}else if(err == -1){
										fprintf(stderr, "Error typechecking : undeclared identifier line %d file %s name of identifier %s\n",yylineno,currName, $2.name);
									}else if(err == -2){
										fprintf(stderr, "Error typechecking : mismatch of type. Type is %s. line %d file %s name of identifier %s\n",typeTranslation[$2.type],yylineno,currName,$2.name); 
									}else if(err == -3){
										fprintf(stderr, "Error typechecking : expected a raw type  got %s line %d file %s identifier %s\n",typeTranslation[$2.type],yylineno,currName,$2.name);
									}
									}
			| IDENT LBRACKET expression RBRACKET {	
													if($1.type < 3){
														fprintf(stderr, "Error typechecking : expected array for identifier %s got %s line %d file %s \n",$1.name,typeTranslation[$1.type],yylineno,currName);
														return 0;
													}
													int err = find_identifier($1.name,$1.type);
													if(err == 0){
														create_node(&$$,$1.type+3);
														set_right(&$$,&$3);
														set_attribute(&$$,&$1,sizeof(identifier));
													}else if(err == -1){
														fprintf(stderr, "Error typechecking : identifier %s not declared line %d file %s\n",$1.name,yylineno,currName);
														
													}else if(err == -2){
														fprintf(stderr, "Error typechecking : identifier %s mismatch of type got type %s. %d file %s\n",$1.name,typeTranslation[$1.type],yylineno,currName);

													}
													}
			| IDENT LPAR  RPAR 					{int ret_type = argument_match($1.name,0,0);
													if(ret_type >= 0){
														//successful
														$$.type = ret_type;
														//todo some more things maybe
														
													}else if(ret_type == -1){
														//no function 
														fprintf(stderr, "error typechecking: function %s does not exist, line %d in file %s\n",$1.name,yylineno,currName);
													}else if(ret_type == -2){
														//mismatch
														fprintf(stderr, "error typechecking : mismatch in arguments for function %s, call in line %d file %s\n",$1.name,yylineno, currName);
														
													}
												}
			| IDENT LPAR expressionlist RPAR  	{int ret_type = argument_match($1.name,ids.size,&ids);
													
													if(ret_type >= 0){
														//successful
														$$.type = ret_type;
														//todo some more things maybe
														
													}else if(ret_type == -1){
														//no function 
														fprintf(stderr, "error typechecking: function %s does not exist, line %d in file %s\n",$1.name,yylineno,currName);
													}else if(ret_type == -2){
														//mismatch
														fprintf(stderr, "error typechecking : mismatch in arguments for function %s, call in line %d file %s\n",$1.name,yylineno, currName);
														
													}
												}
			| lvalue incrdecr	{create_node(&$$,$1.type);
								 set_left(&$$, &$1);
								 int val = $2;
								 set_attribute(&$$,&val,sizeof(int));
								 }
								
			| incrdecr lvalue 	{create_node(&$$,$2.type);
								 set_left(&$$, &$2);
								 int val = $1;
								 set_attribute(&$$,&val,sizeof(int));
								 }
			| lvalue ASSIGN expression {
										if($1.type != $3.type){
											identifier* id = (identifier*)$1.attribute;
											fprintf(stderr, "Error mismatch in assignment expected %s for identifier %s . File %s line %d\n",typeTranslation[$1.type],id->name,currName,yylineno);
										}else{
											//type match. 
											create_node(&$$,$1.type);
											set_left(&$$,&$1);
											set_right(&$$,&$3);
											int val = ASSIGN;
											set_attribute(&$$,&val,sizeof(int));
											
										
										}
										}
			| binaryop {$$ = $1;/*will be done at lower level check */ }
			| unaryop {$$ = $1;/*check at lower lvl*/}
			| ternaryexpr {$$ = $1;/*check at lower lvl*/}
			| LPAR TYPE RPAR expression %prec PARTYPE 	{create_node(&$$,$2);
														 set_left(&$$,&$4);
														}
			| LPAR expression RPAR {$$ = $2;/*nothing*/}
			;			
			
ternaryexpr 		: expression QUEST expression COLON expression {
																	/*check that $3 type == $5 type, and then $$ type = $3 type */
																	if($3.type != $5.type){
																	
																	}else{
																	//match okay.
																	//this one is a bit complicated we need to spawn 2 nodes. and $$ is the parent of those 2 
																	node * quest = malloc(sizeof(node));
																	create_node(quest,$1.type);
																	set_left(quest,&$1);
																	int val = QUEST;
																	set_attribute(quest,&val,sizeof(int));
																	
																	node * colon = malloc(sizeof(node));
																	create_node(colon,$3.type);
																	set_left(colon,&$3);
																	set_right(colon,&$5);
																	val = COLON;
																	set_attribute(colon,&val,sizeof(int));
																	
																	//now $$.left = quest, $$.right = colon
																	set_left(&$$,quest);
																	set_right(&$$,colon);
																	val = QUESTCOLON;
																	set_attribute(&$$,&val,sizeof(int));
																	
																	
																	}
																	}
expressionlist 	: expression COMMA expressionlist {/*add it to the list */}
				| expression {/*finish the list */}
				; 
incrdecr	: INCR 	{$$ = INCR;}
			| DECR 	{$$ = DECR;}
			; 
// careful when using unary minus -> can't do --2 because it will be DECR 2, need to either do - -2 OR -(-2)
unaryop 	: MINUS expression %prec UMINUS {create_node(&$$,NA);
											 set_right(&$$,&$2);
											 int val = UMINUS;
											 set_attribute(&$$,&val,sizeof(int));
											 }
			| BANG expression				{//SOME TYPECHECKING NEEDED. 
											 create_node(&$$,CHAR);
											 set_right(&$$,&$2);
											 int val = BANG;
											 set_attribute(&$$,&val,sizeof(int));
											 }
											 
			| TILDE expression				{create_node(&$$,NA);
											 set_right(&$$,&$2);
											 int val = TILDE;
											 set_attribute(&$$,&val,sizeof(int));
											 }
			; 
			//FOR ALL BELOW WE NEED $1 type == $2 type 
binaryop 	: expression EQUALS expression	{create_node(&$$,NA);
											 int err = to_char_type(&$$,&$1,&$3);
											 if(err>= 0){
												int val = EQUALS;
												set_attribute(&$$,&val,sizeof(int));
											 }else if(err == -1){
											 		 fprintf(stderr,"Error typechecking : line %d in file %s left and right hand side have non matching type ! \n",
														yylineno,currName);

											 }
												
											 }
			| expression NEQUAL expression	{create_node(&$$,NA);
											 int err = to_char_type(&$$,&$1,&$3);
											 if(err>= 0){
												int val = NEQUAL;
												set_attribute(&$$,&val,sizeof(int));
											 }else if(err == -1){
											 		 fprintf(stderr,"Error typechecking : line %d in file %s left and right hand side have non matching type ! \n",
														yylineno,currName);

											 }
											 }
			| expression GE expression		{create_node(&$$,NA);
											 int err = to_char_type(&$$,&$1,&$3); 
											 if(err>= 0){
												int val = GE;
												set_attribute(&$$,&val,sizeof(int));
											 }else if(err == -1){
											 		 fprintf(stderr,"Error typechecking : line %d in file %s left and right hand side have non matching type ! \n",
														yylineno,currName);

											 }
											 }
			| expression GT expression		{create_node(&$$,NA);
											 int err = to_char_type(&$$,&$1,&$3);
											 if(err>= 0){
												int val = GT;
												set_attribute(&$$,&val,sizeof(int));
											 }else if(err == -1){
											 		 fprintf(stderr,"Error typechecking : line %d in file %s left and right hand side have non matching type ! \n",
														yylineno,currName);

											 }
											 }
			| expression LE expression		{create_node(&$$,NA);
											 int err = to_char_type(&$$,&$1,&$3); 
											 if(err>= 0){
												int val = LE;
												set_attribute(&$$,&val,sizeof(int));
											 }else if(err == -1){
											 		 fprintf(stderr,"Error typechecking : line %d in file %s left and right hand side have non matching type ! \n",
														yylineno,currName);

											 }
											 }
			| expression LT expression		{create_node(&$$,NA);
											 int err = to_char_type(&$$,&$1,&$3);
											 if(err>= 0){
												int val = LT;
												set_attribute(&$$,&val,sizeof(int));
											 }else if(err == -1){
											 		 fprintf(stderr,"Error typechecking : line %d in file %s left and right hand side have non matching type ! \n",
														yylineno,currName);

											 }
											 }
			| expression PLUS expression	{create_node(&$$,NA);
										     int op = PLUS;
											 int err = binary_op(&$$,&$1,&$3,&op);
											 if(err == -1){
											 fprintf(stderr,"Error typechecking : line %d in file %s left and right hand side have non matching type ! \n",
														yylineno,currName);
											 }
											 }
			| expression MINUS expression 	{create_node(&$$,NA);
										     int op = MINUS;
											 int err = binary_op(&$$,&$1,&$3,&op);
											 if(err == -1){
											 fprintf(stderr,"Error typechecking : line %d in file %s left and right hand side have non matching type ! \n",
														yylineno,currName);
											 }
											 }
			| expression STAR expression 	{create_node(&$$,NA);
										     int op = STAR;
											 int err = binary_op(&$$,&$1,&$3,&op);
											 if(err == -1){
											 fprintf(stderr,"Error typechecking : line %d in file %s left and right hand side have non matching type ! \n",
														yylineno,currName);
											 }
											 }
			| expression SLASH expression	{create_node(&$$,NA);
										     int op = SLASH;
											 int err = binary_op(&$$,&$1,&$3,&op);
											 if(err == -1){
											 fprintf(stderr,"Error typechecking : line %d in file %s left and right hand side have non matching type ! \n",
														yylineno,currName);
											 }
											 }
			| expression MOD expression		{create_node(&$$,NA);
										     int op = MOD;
											 int err = binary_op(&$$,&$1,&$3,&op);
											 if(err == -1){
											 fprintf(stderr,"Error typechecking : line %d in file %s left and right hand side have non matching type ! \n",
														yylineno,currName);
											 }
											 }
			| expression PIPE expression	{create_node(&$$,NA);
										     int op = PIPE;
										     if($1.type == FLOAT || $3.type == FLOAT){
										     
										     }
											 int err = binary_op(&$$,&$1,&$3,&op);
											 if(err == -1){
											 fprintf(stderr,"Error typechecking : line %d in file %s left and right hand side have non matching type ! \n",
														yylineno,currName);
											 }
											 }
			| expression AMP expression		{create_node(&$$,NA);
											 set_left(&$$,&$1);
											 set_right(&$$,&$3);
											 int val = AMP;
											 set_attribute(&$$,&val,sizeof(int));
											 }
			| expression DPIPE expression	{create_node(&$$,NA);
											 set_left(&$$,&$1);
											 set_right(&$$,&$3);
											 int val = DPIPE;
											 set_attribute(&$$,&val,sizeof(int));
											 }
			| expression DAMP expression	{create_node(&$$,NA);
											 set_left(&$$,&$1);
											 set_right(&$$,&$3);
											 int val = DAMP;
											 set_attribute(&$$,&val,sizeof(int));
											 }
			;
			
constant	: INTCONST	{$$ = $1;/* type is INT */}
			| REALCONST {$$ = $1;/*type is FLOAT */}
			| STRCONST 	{$$ = $1;/*type is CHARARR*/}
			| CHARCONST {$$ = $1;/*type is CHAR*/}
			;


%%


//other code..

/**
 *@brief main code, will load the file if a file is given and start the parsing. 
 *@param argc the argc count
 *@param argv the values of the arguments
 *@return 0 on success
 */
int main(int argc, char** argv)
{
	//initialize the array of defines. (for the lexer)
	initArray(&def_array);

	init_id_list(&ids);
	setup_typecheck();
	
	if(argc > 1){
		//there is a file to open
		yyin = fopen(argv[1],"r");
		//will be freed in process <<EOF>>
		currName = malloc(strlen(argv[1])+1);
		strcpy(currName,argv[1]);
		if(NULL==yyin){
			fprintf(stderr,"Error file %s can't be opened\n",argv[1]);
			exit(1);
		}
		if(argc > 2){
			if(strcmp(argv[2],"debug")==0){
				debug = 1;
			}
			
		}
		//file was opened
		if(debug){printf("Opening file : %s\n", argv[1]);}
		yyparse();
		fclose(yyin);
	}else{
		yyparse();	
		
	}
	//close up everything. 
	close_typecheck();
	
	
}


/**
 *@brief prints an error message if the parsing failed. 
 *@param s the error message
 */
void yyerror (char const *s){
	fprintf(stderr, "Parsing error : line %d in file %s on token :  %s.\n Error :  %s\n",yylineno, currName, yytext, s);
}
