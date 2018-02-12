
%{
	//C declarations..
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "defines.h"
	
	//need this stuff from flex to know about
	extern int yylex();
	extern int yyparse();
	extern FILE *yyin;
	extern define_array def_array;
	extern char* currName;
	extern int debug;
	void yyerror (char const *s);
	
	
%}


// all of our tokens....
%token TYPE
%token FOR
%token WHILE
%token DO
%token IF
%token ELSE
%token BREAK
%token CONTINUE
%token RETURN
%token IDENT
%token INTCONST
%token REALCONST
%token STRCONST
%token CHARCONST
%token LPAR
%token RPAR
%token LBRACKET
%token RBRACKET
%token LBRACE
%token RBRACE
%token SEMI
%token QUEST
%token COLON



%token BANG
%token TILDE
%token MINUS
%token INCR
%token DECR

%token STAR
%token SLASH
%token MOD

%token PLUS

%token GT
%token GE
%token LT
%token LE

%token EQUALS
%token NEQUAL

%token AMP
%token DAMP
%token PIPE
%token DPIPE
%token ASSIGN
%token COMMA


//we set the associativity left to right or right to left..
%left LPAR RPAR STAR SLASH MOD PLUS MINUS GT GE LT LE EQUALS NEQUAL
%left  AMP PIPE DAMP DPIPE COMMA
/*
Operator precedence is determined by the 
line ordering of the declarations; the higher the line number 
of the declaration (lower on the page or screen), 
the higher the precedence. 
From : https://www.gnu.org/software/bison/manual/html_node/Infix-Calc.html#Infix-Calc */
%start program 

%% 
//Grammar goes here..
//The abstract part 
program : sentences | %empty	; 
sentences : sentence sentences  | sentence	; 
sentence : variabledeclaration | functionprototype | functiondefinition ; 

//about variable declaration : THIS IS OK (no conflict)
variabledeclaration : TYPE listidentifiers SEMI ; 
listidentifiers : declaration COMMA listidentifiers | declaration ; 
declaration : IDENT | IDENT LPAR INTCONST RPAR ; 

//about function prototypes : THIS IS OK ( no conflict ) 
functionprototype : functiondeclaration SEMI ; 
functiondeclaration : TYPE IDENT LPAR formallistparameters RPAR 	
formallistparameters : formalparameter COMMA formallistparameters | formalparameter ; 
formalparameter : TYPE IDENT | TYPE IDENT LBRACKET RBRACKET ; 

//about function definitions.
functiondefinition : functiondeclaration LBRACE declarationsorstatements RBRACE | functiondeclaration LBRACE RBRACE; 
declarationsorstatements : declorstat declarationsorstatements | declorstat ; 
declorstat : declaration | statement  ;  //TODO maybe add | statementblock
statementblock : LBRACE liststatement RBRACE | LBRACE RBRACE; 
liststatement : statement liststatement | statement ; 

//about statements...
statement :  SEMI | BREAK SEMI | CONTINUE SEMI | RETURN SEMI 
			| RETURN expression SEMI | ifstatement | forstatement | whilestatement | dowhilestatement ; 
//more specifics on statements 

ifstatement : IF LPAR expression RPAR statementorblock | IF LPAR expression RPAR statementorblock ELSE statementorblock ;
statementorblock : statement | statementblock ; 

forstatement : FOR LPAR optionalexpression SEMI optionalexpression SEMI optionalexpression RPAR
optionalexpression : expression | %empty;
whilepart : WHILE LPAR expression RPAR ; 
whilestatement : whilepart statementorblock SEMI ; 
dowhilestatement : DO statementorblock whilepart SEMI ; 

//about expressions. 
expression : parenthesisexpression| unaryexpr| litteral | identexpression | lvalueexpr ; 
expressionlist : expression COMMA expressionlist | expression ; 
litteral : STRCONST | INTCONST | REALCONST | CHARCONST;

identexpression : IDENT | AMP IDENT | IDENT LPAR expressionlist RPAR ;
lvalueexpr : lvalue ASSIGN expression | INCR lvalue | lvalue INCR | DECR lvalue | lvalue DECR ; 
unaryexpr : unaryop expression | expression binaryop expression | expression QUEST expression COLON expression ; 
parenthesisexpression : LPAR TYPE RPAR expression | LPAR expression RPAR ; 

//others for statement
lvalue : IDENT | IDENT LBRACKET expression RBRACKET ; 
unaryop : MINUS | BANG | TILDE ; 
binaryop : EQUALS | NEQUAL | GT | GE | LT | LE | PLUS | MINUS | STAR |
			SLASH | MOD | AMP | PIPE | DPIPE | DAMP ; 

%%


//other code..


int main(int argc, char** argv)
{
printf("Starting \n");
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



void yyerror (char const *s){
	fprintf(stderr, "Error while parsing : %s\n",s);
}
