/***********************************
 * A basic lexer for the 
 * COMS440 project
 * Johan Lanzrein
 ************************************/


%{
/*This is the header, global defs, etc..*/
#include <unistd.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "tokens.h"
%}

/*Definitions..*/

TYPE (char)|(int)|(float)
FOR for
WHILE while
DO do
IF if
ELSE else
BREAK break
CONTINUE continue
RETURN return

IDENT [_a-zA-Z][_a-zA-Z0-9]*
INTCONST [0-9]*
REALCONST [0-9]*+"."[0-9]*
STRCONST \"(\\.|[^\\"])*\"
CHARCONST \'.\'

LPAR \(
RPAR \)
LBRACKET \[
RBRACKET \]
LBRACE \{
RBRACE \}

COMMA ,
SEMI ;
QUEST \?
COLON :

EQUALS == 
NEQUAL !=
GT > 
GE >= 
LT <
LE <= 
ASSIGN =
INCR \+\+
DECR --
PLUS \+
MINUS - 
STAR \*
SLASH \/
MOD %
TILDE ~
PIPE \|
AMP & 
BANG !
DPIPE \|\|
DAMP &&

%%
{TYPE} 	{printf("This is a %s : %s\n",TOKENS_MAP[0].translation,yytext);}
{FOR}	{printf("Keywork %s \n", TOKENS_MAP[1].translation);}
{WHILE}	{printf("Keywork %s \n", TOKENS_MAP[2].translation);}
{DO}	{printf("Keywork %s \n", TOKENS_MAP[3].translation);}
{IF}	{printf("Keywork %s \n", TOKENS_MAP[4].translation);}
{ELSE}	{printf("Keywork %s \n", TOKENS_MAP[5].translation);}
{BREAK}	{printf("Keywork %s \n", TOKENS_MAP[6].translation);}
{CONTINUE}	{printf("Keywork %s \n", TOKENS_MAP[7].translation);}
{RETURN}	{printf("Keywork %s \n", TOKENS_MAP[8].translation);}

{IDENT}		{printf("Detected %s : %s\n",TOKENS_MAP[9].translation, yytext);}

{INTCONST} 	{printf("Detected %s : %d",TOKENS_MAP[10].translation, atoi(yytext));}
{REALCONST} 	{printf("Detected %s : %f\n",TOKENS_MAP[11].translation, atof(yytext));} // the current text is yytext
{STRCONST}    {
				printf("%s detected\n", TOKENS_MAP[12].translation);
				if(strlen(yytext) > 2){
					char* str = malloc(strlen(yytext)); 
					strncpy(str,yytext+1,strlen(yytext)-2);
					printf("String with value : %s\n",str);
					free(str);
				}else{
					printf("There is an emptry string\n");
				}
			}
			
{CHARCONST}	{printf("%s detected : %s\n",TOKENS_MAP[13].translation,yytext);}

{LPAR}		{printf("%s detected\n", TOKENS_MAP[14].translation);}
{RPAR}		{printf("%s detected\n", TOKENS_MAP[15].translation);}
{LBRACKET}	{printf("%s detected\n", TOKENS_MAP[16].translation);}
{RBRACKET}	{printf("%s detected\n", TOKENS_MAP[17].translation);}
{LBRACE}	{printf("%s detected\n", TOKENS_MAP[18].translation);}
{RBRACE}	{printf("%s detected\n", TOKENS_MAP[19].translation);}

{COMMA}	{printf("%s detected\n", TOKENS_MAP[20].translation);}
{SEMI}	{printf("%s detected\n", TOKENS_MAP[21].translation);}
{QUEST}	{printf("%s detected\n", TOKENS_MAP[22].translation);}
{COLON}	{printf("%s detected\n", TOKENS_MAP[23].translation);}

{EQUALS}	{printf("%s detected\n", TOKENS_MAP[24].translation);}
{NEQUAL}	{printf("%s detected\n", TOKENS_MAP[25].translation);}
{GT}	{printf("%s detected\n", TOKENS_MAP[26].translation);}
{GE}	{printf("%s detected\n", TOKENS_MAP[27].translation);}
{LT}	{printf("%s detected\n", TOKENS_MAP[28].translation);}
{LE}	{printf("%s detected\n", TOKENS_MAP[29].translation);}
{ASSIGN}	{printf("%s detected\n", TOKENS_MAP[30].translation);}
{INCR}	{printf("%s detected\n", TOKENS_MAP[31].translation);}
{DECR}	{printf("%s detected\n", TOKENS_MAP[32].translation);}
{PLUS}	{printf("%s detected\n", TOKENS_MAP[33].translation);}
{MINUS}	{printf("%s detected\n", TOKENS_MAP[34].translation);}
{STAR}	{printf("%s detected\n", TOKENS_MAP[35].translation);}
{SLASH}	{printf("%s detected\n", TOKENS_MAP[36].translation);}
{MOD}	{printf("%s detected\n", TOKENS_MAP[37].translation);}
{TILDE}	{printf("%s detected\n", TOKENS_MAP[38].translation);}
{PIPE}	{printf("%s detected\n", TOKENS_MAP[39].translation);}
{AMP}	{printf("%s detected\n", TOKENS_MAP[40].translation);}
{BANG}	{printf("%s detected\n", TOKENS_MAP[41].translation);}
{DPIPE}	{printf("%s detected\n", TOKENS_MAP[42].translation);}
{DAMP}	{printf("%s detected\n", TOKENS_MAP[43].translation);}

<<EOF>> 	{printf("File is over!\n");yyterminate();}
%%



int main(int argc, char** argv)
{
  if(argc > 1){
	//there is a file to open
	yyin = fopen(argv[1],"r");
	if(NULL==yyin){
		fprintf(stderr,"Error file %s can't be opened\n",argv[1]);
		exit(1);
	}
	//file was opened
	printf("Opening file : %s\n", argv[1]);
	yylex();
	fclose(yyin);
  }else{
	yylex();	
	return 0;
  }
}
