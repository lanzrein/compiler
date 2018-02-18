
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


// all of our tokens....
%token TYPE
%token FOR
%token WHILE
%token DO
%token IF
%left NOTELSE //pseudo token. 
%left ELSE
%token BREAK
%token CONTINUE
%token RETURN
%token IDENT
%token INTCONST
%token REALCONST
%token STRCONST
%token CHARCONST

%token LBRACE
%token RBRACE
%token SEMI
%token QUEST
%token COLON




//we set the associativity left to right or right to left..
%left COMMA
%right ASSIGN
%right QUESTCOLON
%left DPIPE
%left DAMP
%left PIPE
%left AMP 
%left EQUALS NEQUAL
%left GT GE LT LE
%left PLUS MINUS 
%left STAR SLASH MOD 
%right BANG TILDE DECR INCR  
%right UMINUS UAMP
%left LPAR RPAR LBRACKET RBRACKET 

/*
Operator precedence is determined by the 
line ordering of the declarations; the higher the line number 
of the declaration (lower on the page or screen), 
the higher the precedence. 
From : https://www.gnu.org/software/bison/manual/html_node/Infix-Calc.html#Infix-Calc */

%start program 

%% 
//Grammar goes here..
//The general part 
program : sentences ; 
sentences : sentence sentences | sentence	; 
sentence : variabledeclaration | functionprototype | functiondefinition ; 

//about variable declaration : THIS IS OK (no conflict)
variabledeclaration : TYPE listidentifiers SEMI ; 
listidentifiers : declaration COMMA listidentifiers | declaration ; 
declaration : IDENT LBRACKET INTCONST RBRACKET | IDENT; 

//about function prototypes : THIS IS OK ( no conflict ) 
functionprototype : functiondeclaration SEMI ; 
functiondeclaration : TYPE IDENT LPAR formallistparameters RPAR | TYPE IDENT LPAR RPAR;	
formallistparameters : formalparameter COMMA formallistparameters | formalparameter ; 
formalparameter : TYPE IDENT | TYPE IDENT LBRACKET RBRACKET ; 

//about function definitions.
functiondefinition : functiondeclaration LBRACE body RBRACE | functiondeclaration LBRACE RBRACE; 
body : declorstat body | declorstat ; 
declorstat : variabledeclaration | statement  | statementblock
statementblock : LBRACE liststatement RBRACE | LBRACE RBRACE; 
liststatement : statement liststatement | statement ; 

//about statements...

statement : keywords SEMI | RETURN expression SEMI | expression SEMI | ifstatement | forstatement | whilestatement | dowhilestatement ; 
keywords : BREAK | CONTINUE; 
//more specifics on statements 

ifstatement : IF LPAR expression RPAR statementorblock ELSE statementorblock | IF LPAR expression RPAR statementorblock %prec NOTELSE;
statementorblock : statement | statementblock ; 

forstatement : FOR LPAR optionalexpression SEMI optionalexpression SEMI optionalexpression RPAR statementorblock
optionalexpression : expression  | %empty ;
whilepart : WHILE LPAR expression RPAR ; 
whilestatement : whilepart statementorblock SEMI ; 
dowhilestatement : DO statementorblock whilepart SEMI ; 

lvalue : IDENT optionbrack  ;
optionbrack : LBRACKET expression RBRACKET | %empty;	
//RENAME FOR MORE CLARITY....
expression 	: constant | IDENT | AMP IDENT %prec UAMP | IDENT LBRACKET expression RBRACKET 
			| IDENT LPAR  RPAR | IDENT LPAR expressionlist RPAR  
			| lvalue incrdecr | incrdecr lvalue 
			| lvalue ASSIGN expression | unaryop expression | expression binaryop expression 
			| expression QUEST expression COLON expression %prec QUESTCOLON 
			| LPAR TYPE RPAR expression | LPAR expression RPAR ;
			
expressionlist : expression COMMA expressionlist | expression ; 
incrdecr	: INCR | DECR ; 
// careful when using unary minus -> can't do --2 because it will be DECR 2, need to either do - -2 OR -(-2)
unaryop 	: MINUS %prec UMINUS | BANG | TILDE ; 
binaryop 	: EQUALS | NEQUAL | GE | GT | LE | LT
			| PLUS | MINUS | STAR | SLASH | MOD | PIPE | AMP | DPIPE | DAMP;
constant	: INTCONST | REALCONST | STRCONST | CHARCONST;


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
	fprintf(stderr, "Error line %d in file %s while parsing on token :  %s.\n Error :  %s\n",yylineno, currName, yytext, s);
}
