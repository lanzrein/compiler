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

//this is for our parsing of defines.
#define MAX_INCLUDE_DEPTH 1024
YY_BUFFER_STATE includes_stack[MAX_INCLUDE_DEPTH];
char* filenameStack[MAX_INCLUDE_DEPTH];
char* currName;
int currPtr = 0;
int debug = 0;
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
INCLUDE #include

%x COMMENTSINGLE
%x COMMENTMULTI
%x INCLUDECND
%%
{INCLUDE}	{if(debug){printf("Including a new file.\n");}BEGIN(INCLUDECND);}
<INCLUDECND>[ \t]* /*discard white*/
<INCLUDECND>{STRCONST}	{
							//check fo rmax depth
							if(currPtr >= MAX_INCLUDE_DEPTH){
								fprintf(stderr,"Reached max include depth!");
								BEGIN(INITIAL);
							}
							if(debug){printf("Starting to include new file %s\n",yytext);}
							int length = strlen(yytext)-2;
							//check if valid name..
							if(length<0){
								fprintf(stderr,"Length of file name is not long enough.\n");
								BEGIN(INITIAL);
							}
							//take the name and remove the quotes
							char* name = malloc(length);
							memcpy(name,yytext+1,length);
							name[length] = '\0';
							
							
							
							includes_stack[currPtr++] = YY_CURRENT_BUFFER;
							
							if(debug){printf("Name : %s\n",name);}
							
							yyin = fopen(name,"r");
							if(NULL==yyin){
								fprintf(stderr,"Couldn't open file.\n");
								yy_switch_to_buffer(includes_stack[currPtr]);
								currPtr--;
								BEGIN(INITIAL);
							}
							//set the file name.
							filenameStack[currPtr-1] = malloc(strlen(currName));
							memcpy(filenameStack[currPtr-1],currName,strlen(currName));
							filenameStack[currPtr-1][strlen(currName)] = '\0';
							memcpy(currName,name,length);
							currName[length] = '\0';
							free(name);
							
							yy_switch_to_buffer(yy_create_buffer(yyin,YY_BUF_SIZE));
							BEGIN(INITIAL);
						}
							
								
							
<INCLUDECND>"."	{fprintf(stderr,"Error expected file name in quotes got : %s.\n",yytext);BEGIN(INITIAL);}


"\/\*"		{if(debug){printf("Multi line comment start\n");}BEGIN(COMMENTMULTI);}
<COMMENTMULTI>\n	{yylineno++;}
<COMMENTMULTI>[^*\n]*	/*discard*/
<COMMENTMULTI>"*"+[^*/\n]* /*discard*/
<COMMENTMULTI>"*"+"/"	{if(debug){printf("End of multi line comment\n");}BEGIN(INITIAL);}


"\/\/"		{if(debug){printf("Comment detected.\n");}BEGIN(COMMENTSINGLE);}
<COMMENTSINGLE>"\n"	{if(debug){printf("End of comment ! \n");}yylineno++;BEGIN(INITIAL);}
<COMMENTSINGLE>[^\n]	{/* discard */}

{TYPE} 	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[0].translation,yytext);}
{FOR}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[1].translation,yytext);}
{WHILE}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[2].translation,yytext);}
{DO}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[3].translation,yytext);}
{IF}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[4].translation,yytext);}
{ELSE}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[5].translation,yytext);}
{BREAK}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[6].translation,yytext);}
{CONTINUE}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[7].translation,yytext);}
{RETURN}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[8].translation,yytext);}

{IDENT}		{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[9].translation,yytext);}

{INTCONST} 	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[10].translation,yytext);}
{REALCONST} 	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[11].translation,yytext);} // the current text is yytext
{STRCONST}    {
				if(strlen(yytext) > 2){
					char* str = malloc(strlen(yytext)-2); 
					strncpy(str,yytext+1,strlen(yytext)-2);
					str[strlen(yytext)-2]='\0';
					printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[12].translation,str);
					free(str);
				}else{
					printf("There is an emptry string\n");
				}
			}
			
{CHARCONST}	{printf("File %s Line %d Token %s \'%c\'\n",currName,yylineno,TOKENS_MAP[13].translation,yytext[1]);}

{LPAR}		{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[14].translation,yytext);}
{RPAR}		{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[15].translation,yytext);}
{LBRACKET}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[16].translation,yytext);}
{RBRACKET}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[17].translation,yytext);}
{LBRACE}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[18].translation,yytext);}
{RBRACE}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[19].translation,yytext);}

{COMMA}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[20].translation,yytext);}
{SEMI}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[21].translation,yytext);}
{QUEST}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[22].translation,yytext);}
{COLON}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[23].translation,yytext);}

{EQUALS}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[24].translation,yytext);}
{NEQUAL}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[25].translation,yytext);}
{GT}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[26].translation,yytext);}
{GE}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[27].translation,yytext);}
{LT}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[28].translation,yytext);}
{LE}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[29].translation,yytext);}
{ASSIGN}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[30].translation,yytext);}
{INCR}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[31].translation,yytext);}
{DECR}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[32].translation,yytext);}
{PLUS}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[33].translation,yytext);}
{MINUS}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[34].translation,yytext);}
{STAR}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[35].translation,yytext);}
{SLASH}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[36].translation,yytext);}
{MOD}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[37].translation,yytext);}
{TILDE}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[38].translation,yytext);}
{PIPE}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[39].translation,yytext);}
{AMP}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[40].translation,yytext);}
{BANG}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[41].translation,yytext);}
{DPIPE}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[42].translation,yytext);}
{DAMP}	{printf("File %s Line %d Token %s \'%s\'\n",currName,yylineno,TOKENS_MAP[43].translation,yytext);}

[ \t]* /* discard white*/
\n 	{yylineno++;}
"." {fprintf(stderr,"File %s Line %d Unexpected token \'%s\'\n",currName,yylineno,yytext);}


<<EOF>> 	{if(debug){printf("File %s is over! Line total : %d\n",currName,yylineno);}
				if(0==currPtr){
					free(currName);
					yyterminate();
				}else{
					currPtr--;
					//buffer change
					yy_delete_buffer(YY_CURRENT_BUFFER);
					yy_switch_to_buffer(includes_stack[currPtr]);
					//name change.
					currName = realloc(currName,strlen(filenameStack[currPtr]));
					
					memcpy(currName,filenameStack[currPtr],strlen(filenameStack[currPtr]));
					currName[strlen(filenameStack[currPtr])] = '\0';
					
				}
			}
%%



int main(int argc, char** argv)
{
  if(argc > 1){
	//there is a file to open
	yyin = fopen(argv[1],"r");
	//will be freed in process <<EOF>>
	currName = malloc(strlen(argv[1]));
	memcpy(currName,argv[1],strlen(argv[1]));
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
