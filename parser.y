
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
	extern int yylineno;
	extern char* currName; 
	
	
%}


// all of our tokens....
%token TYPE
%token FOR
%token WHILE
%token DO
%token IF
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
%left LPAR RPAR LBRACKET RBRACKET 
%right BANG TILDE DECR INCR AMP 
%left STAR SLASH MOD 
%left PLUS MINUS 
%left GT GE LT LE
%left EQUALS NEQUAL
%left PIPE
%left DAMP
%left DPIPE
%right ASSIGN
%left COMMA

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
program : sentences ;	; 
sentences : sentence sentences  | sentence	; 
sentence : variabledeclaration | functionprototype | functiondefinition ; 

//about variable declaration : THIS IS OK (no conflict)
variabledeclaration : TYPE listidentifiers SEMI ; 
listidentifiers : declaration COMMA listidentifiers | declaration ; 
declaration : IDENT LPAR INTCONST RPAR | IDENT ; 

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

statement : keywords SEMI | RETURN expression SEMI | expression SEMI | ifstatement | forstatement | whilestatement | dowhilestatement ; 
//optionreturn : RETURN | %empty;
keywords : BREAK | CONTINUE; 
//more specifics on statements 

ifstatement : IF LPAR expression RPAR statementorblock optionelse;
optionelse : ELSE statementblock | %empty;
statementorblock : statement | statementblock ; 

forstatement : FOR LPAR optionalexpression SEMI optionalexpression SEMI optionalexpression RPAR
optionalexpression : expression  | %empty ;
whilepart : WHILE LPAR expression RPAR ; 
whilestatement : whilepart statementorblock SEMI ; 
dowhilestatement : DO statementorblock whilepart SEMI ; 

lvalue : IDENT optionbrack;
optionbrack : LBRACKET expression RBRACKET | %empty;	
//RENAME FOR MORE CLARITY....
expression : expression1  ;
expression1 : expression2 COMMA expression1 | expression2;
expression2 : expression2 ASSIGN expression3 | expression3;
expression3 : expression3 QUEST expression4 COLON expression4  | expression4;
expression4 : expression4 DPIPE expression5 | expression5;
expression5 : expression5 DAMP expression6 | expression6;
expression6 : expression6 PIPE expression7 | expression7;
expression7 : expression7 AMP expression8 | expression8;
expression8 : expression8 eqneqop expression9 | expression9;
eqneqop : EQUALS | NEQUAL;
expression9 : expression9 compop expression10 | expression10;
compop : GT | GE | LT | LE;
expression10 :  expression10 plusminus expression11 | expression11;
plusminus : PLUS | MINUS;
expression11 : expression11 starslashmodop expression12 | expression12;
starslashmodop : STAR | SLASH | MOD;
expression12 : unaryop expression12 | incrdecr lvalue | lvalue incrdecr 
				|expression13;
incrdecr : INCR | DECR;
unaryop : BANG | TILDE | MINUS | AMP ;
expression13 : LPAR TYPE RPAR expression13 | LPAR expression13 RPAR | constant;
constant : CHARCONST | INTCONST | REALCONST | STRCONST;



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
	fprintf(stderr, "Error line %d in file %s while parsing : %s\n",yylineno, currName,  s);
}
