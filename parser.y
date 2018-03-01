%code requires {

	#include "node.h"

}

%{
	//C declarations..
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "defines.h"
	
	
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

	
%}

%union{
	node n;
}



// all remaining tokens....
%token <n> TYPE
%token <n> FOR
%token <n> WHILE
%token <n> DO
%token <n> IF
%left <n> NOTELSE //pseudo token. 
%left <n> ELSE
%token <n> BREAK
%token <n> CONTINUE
%token <n> RETURN
%token <n> IDENT
%token <n> INTCONST
%token <n> REALCONST
%token <n> STRCONST
%token <n> CHARCONST

%token <n> LBRACE RBRACE
%token <n> SEMI


//we set priority and the associativity left to right or right to left..
%left <n> COMMA
%right <n> ASSIGN
%right <n> QUEST COLON QUESTCOLON //psuedo token for ternary expression (expr ? expr : expr)
%left <n> DPIPE
%left <n> DAMP
%left <n> PIPE
%left <n> AMP 
%left <n> EQUALS NEQUAL
%left <n> GT GE LT LE
%left <n> PLUS MINUS 
%left <n> STAR SLASH MOD 
%right <n> BANG TILDE DECR INCR  UAMP UMINUS PARTYPE //pseudo token for casting ((type) )
%left <n> LPAR RPAR LBRACKET RBRACKET 





//This are the values that come from lexer..



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
variabledeclaration : TYPE listidentifiers SEMI ; 
listidentifiers : declaration COMMA listidentifiers 
				| declaration 
				; 
declaration : IDENT LBRACKET INTCONST RBRACKET 
			| IDENT
			; 

//about function prototypes : THIS IS OK ( no conflict ) 
functionprototype : functiondeclaration SEMI ; 
functiondeclaration : TYPE IDENT LPAR formallistparameters RPAR 
					| TYPE IDENT LPAR RPAR
					;	
formallistparameters 	: formalparameter COMMA formallistparameters 
						| formalparameter 
						; 
formalparameter : TYPE IDENT 
				| TYPE IDENT LBRACKET RBRACKET 
				; 

//about function definitions.
functiondefinition 	: functiondeclaration LBRACE body RBRACE 
					| functiondeclaration LBRACE RBRACE
					; 
body 	: declorstat body 
		| declorstat 
		; 
declorstat 	: variabledeclaration 
			| statement  
			| statementblock 
			; 
statementblock 	: LBRACE liststatement RBRACE 
				| LBRACE RBRACE
				; 
liststatement 	: statement liststatement 
				| statement 
				; 

//about statements...

statement 	: SEMI
			keywords SEMI
			| RETURN expression SEMI {/*check if correct return type*/}
			| expression SEMI {/*TODO show th eline in the std output*/}
			| ifstatement 
			| forstatement 
			| whilestatement 
			| dowhilestatement 
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
optionalexpression 	: expression  
					| %empty 
					;
whilepart : WHILE LPAR expression RPAR ; 
whilestatement : whilepart statementorblock ; 
dowhilestatement : DO statementorblock whilepart SEMI ; 

lvalue : IDENT optionbrack  ;
optionbrack : LBRACKET expression RBRACKET 
			| %empty
			;	
expression 	: constant
			| IDENT 
			| AMP IDENT %prec UAMP 
			| IDENT LBRACKET expression RBRACKET 
			| IDENT LPAR  RPAR {/*check for func ccall*/}
			| IDENT LPAR expressionlist RPAR  {/*check for func call*/}
			| lvalue incrdecr
			| incrdecr lvalue 
			| lvalue ASSIGN expression {/*todo here we need to check for assignment*/}
			| binaryop 
			| unaryop 
			| ternaryexpr
			| LPAR TYPE RPAR expression %prec PARTYPE
			| LPAR expression RPAR
			;			
			
ternaryexpr 		: expression QUEST expression COLON expression 
expressionlist 	: expression COMMA expressionlist 
				| expression 
				; 
incrdecr	: INCR 
			| DECR 
			; 
// careful when using unary minus -> can't do --2 because it will be DECR 2, need to either do - -2 OR -(-2)
unaryop 	: MINUS expression %prec UMINUS 
			| BANG expression
			| TILDE expression
			; 
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
			
constant	: INTCONST	
			| REALCONST 
			| STRCONST 
			| CHARCONST
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
		return 0;
	}
}


/**
 *@brief prints an error message if the parsing failed. 
 *@param s the error message
 */
void yyerror (char const *s){
	fprintf(stderr, "Parsing error : line %d in file %s on token :  %s.\n Error :  %s\n",yylineno, currName, yytext, s);
}
