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
%type <n> expression

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
														delete_id_list(&ids);
														
													} ; 
listidentifiers : declaration COMMA listidentifiers  {add_id(&ids,&$1);}
				| declaration 			{add_id(&ids,&$1);}
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
whilepart : WHILE LPAR expression RPAR  {/*TODO show th eline in the std output*/};
whilestatement : whilepart statementorblock ; 
dowhilestatement : DO statementorblock whilepart SEMI ; 

lvalue : IDENT optionbrack  ;
optionbrack : LBRACKET expression RBRACKET {/*TODO show th eline in the std output*/}
			| %empty
			;	
expression 	: constant	{/*set the node $$ as the value of $1*/}
			| IDENT {/* node $$ as $1 check if ident is declared. */}
			| AMP IDENT %prec UAMP {/*check if declared, if types >=3, and then its type -3 */}
			| IDENT LBRACKET expression RBRACKET {/*check if declared, if types >= 3, and $3 is int else error */}
			| IDENT LPAR  RPAR {/*check for func ccall*/}
			| IDENT LPAR expressionlist RPAR  {/*check for func call*/}
			| lvalue incrdecr {/*something but what ???*/}
			| incrdecr lvalue {/*something but what ???*/}
			| lvalue ASSIGN expression {/*todo here we need to check for assignment type match*/}
			| binaryop {/*will be done at lower level check */ }
			| unaryop {/*check at lower lvl*/}
			| ternaryexpr {/*check at lower lvl*/}
			| LPAR TYPE RPAR expression %prec PARTYPE {/*casting operation */}
			| LPAR expression RPAR {/*nothing*/}
			;			
			
ternaryexpr 		: expression QUEST expression COLON expression {/*check that $3 type == $5 type, and then $$ type = $3 type */}
expressionlist 	: expression COMMA expressionlist {/*add it to the list */}
				| expression {/*finish the list */}
				; 
incrdecr	: INCR 
			| DECR 
			; 
// careful when using unary minus -> can't do --2 because it will be DECR 2, need to either do - -2 OR -(-2)
unaryop 	: MINUS expression %prec UMINUS 
			| BANG expression
			| TILDE expression
			; 
			//FOR ALL BELOW WE NEED $1 type == $2 type 
binaryop 	: expression EQUALS expression
			| expression NEQUAL expression 
			| expression GE expression
			| expression GT expression
			| expression LE expression
			| expression LT expression
			| expression PLUS expression
			| expression MINUS expression 
			| expression STAR expression 
			| expression SLASH expression
			| expression MOD expression
			| expression PIPE expression
			| expression AMP expression
			| expression DPIPE expression
			| expression DAMP expression
			;
			
constant	: INTCONST	{/* type is INT */}
			| REALCONST {/*type is FLOAT */}
			| STRCONST {/*type is CHARARR*/}
			| CHARCONST {/*type is CHAR*/}
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
	
}


/**
 *@brief prints an error message if the parsing failed. 
 *@param s the error message
 */
void yyerror (char const *s){
	fprintf(stderr, "Parsing error : line %d in file %s on token :  %s.\n Error :  %s\n",yylineno, currName, yytext, s);
}
