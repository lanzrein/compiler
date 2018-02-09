
%{
	//C declarations..
	#include <stdio.h>
	#include <defines.h>
	
	//need this stuff from flex to know about
	extern "C" int yylex();
	extern "C" int yyparse();
	extern "C" FILE *yyin;
	extern define_array def_array;

	
	
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
%token COMMA
%token SEMI
%token QUEST
%token COLON
%token EQUALS
%token NEQUAL
%token GT
%token GE
%token LT
%token LE
%token ASSIGN
%token INCR
%token DECR
%token PLUS
%token MINUS
%token STAR
%token SLASH
%token MOD
%token TILDE
%token PIPE
%token AMP
%token BANG
%token DPIPE
%token DAMP

%start program 

%% 
//Grammar goes here..
//The abstract part 
program : sentences ; 
sentences : sentence sentences  ; 
sentence : variabledeclaration | functionprototype | functiondefinition ; 

//about variable declaratoin 
variabledeclaration : TYPE listidentifiers SEMI ; 
listidentifiers : declaration COMMA listidentifiers | listidentifiers ; 
declaration : IDENT | IDENT LPAR INTCONST RPAR ; 

//about function prototypes 
functionprototype : functiondeclaration SEMI ; 
functiondeclaration : TYPE IDENT LPAR formallistparameters RPAR ; 
formallistparameters : formalparameter COMMA formallistparameters | formallistparameters ; 
formalparameter : TYPE IDENT | TYPE IDENT LBRACKET RBRACKET ; 

//about function definitions.
functiondefinition : functiondeclaration LBRACE declarationsorstatements RBRACE ; 
declarationsorstatements : declorstat declarationsorstatements | declarationsorstatements ; 
declorstat : declaration | statement ;  //TODO maybe add | statementblock
statementblock : LBRACE liststatement RBRACE ; 
liststatement : statement liststatement | liststatement ; 

//about statements...
statement : SEMI | expression SEMI | BREAK SEMI | CONTINUE SEMI | RETURN SEMI 
			| RETURN expression SEMI | ifstatement | forstatement | whilestatement | dowhilestatement ; 
//more specifics on statements 
ifstatement : IF LPAR expression RPAR statementorblock ; 
statementorblock : statement | statementblock ; 

forstatement : FOR LPAR //TODO make it.. :'(
whilepart : WHILE LPAR expression RPAR ; 
whilestatement : whilepart statementorblock ; 
dowhilestatement : DO statementorblock whilepart SEMI ; 

//about expressions. 
expression : INTCONST | REALCONST | IDENT | IDENT AMP | identexpression | lvalueexpr ; 
expressionlist : expression COMMA expressionlist | expressionlist ; 

identexpression : IDENT | IDENT AMP | IDENT LPAR expressionlist RPAR
lvalueexpr : lvalue ASSIGN expression | INCR lvalue | lvalue INCR | DECR lvalue | lvalue DECR ; 
unaryexpr : unaryop expression | expression binaryop expression | expression QUEST expression COLON expression ; 
parenthesisexpression : LPAR TYPE RPAR expression | LPAR expression RPAR ; 
lvalue : IDENT | IDENT LPAR expression RPAR ; 
unaryop : MINUS | BANG | TILDE ; 
binaryop : EQUALS | NEQUAL | GT | GE | LT | LE | PLUS | MINUS | STAR |
			SLASH | MOD | AMP | PIPE | DPIPE | DAMP ; 


%%


//other code..


int main(int argc, char** argv)
{
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
	yylex();
	fclose(yyin);
  }else{
	yylex();	
	return 0;
  }
}
