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
#include "defines.h"


int debug = 0;
int closeFile();


//this is for our parsing of include.
#define MAX_INCLUDE_DEPTH 1024
YY_BUFFER_STATE includes_stack[MAX_INCLUDE_DEPTH];
char* filenameStack[MAX_INCLUDE_DEPTH];
char* currName;
int currPtr = 0;
//This is for our define parsing. 
char* identifier; 
char currentText[MAX_DEFINE_LENGTH]; 
define_array def_array = {0,0,};
#define MAX_DEFINE_DEPTH MAX_INCLUDE_DEPTH
YY_BUFFER_STATE defineFile;
char* currSubstitution[MAX_DEFINE_LENGTH];
int substitutionPointer = 0;



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
INTCONST [-+]?[0-9]+
REALCONST ([-+]?[0-9]+(\.[0-9]?)+([eE][-+]?[0-9]+)?)|([-+]?\.[0-9]+([eE][-+]?[0-9]+)?)
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
DEFINE #define
UNDEFINE #undef




%x COMMENTSINGLE
%x COMMENTMULTI
%x INCLUDECND
%x DEFINECND
%x LFTEXT
%x UNDEFCND
%%
{DEFINE}	{if(debug){printf("new define encoutered\n");}if(def_array.cursor > MAX_DEFINES){fprintf(stderr,"Error too many defines\n");}else{BEGIN(DEFINECND);}}
<DEFINECND>[ \t]* /* discard white */
<DEFINECND>{IDENT} {
					  identifier = malloc(strlen(yytext)+1);
					  strcpy(identifier, yytext);
					  //start looking for text. 
					  BEGIN(LFTEXT);
					 }
<LFTEXT>[^\n]	{
					if(strlen(currentText) > 4096){
						fprintf(stderr,"Error on %s length of text too big\n",currentText);
						BEGIN(INITIAL);
					}else{
						strcat(currentText,yytext);
					}
				}
					

<LFTEXT>\n		{
					if(debug){
						printf("End of define %s \n %s \n",identifier, currentText);
					}
					//create the define
					define* newDef = malloc(sizeof(define));
					memset(currSubstitution,0,MAX_DEFINE_LENGTH);
					substitutionPointer = currPtr;
					
					
					
					
					allocDefine(newDef,identifier, currentText);
					//add it to the list
					addNode(&(def_array), newDef);
					memset(currentText,0,strlen(currentText));
					BEGIN(INITIAL);
				}
				
{UNDEFINE}	{if(debug){printf("Start undefining\n");}
				BEGIN(UNDEFCND);
			}
<UNDEFCND>{IDENT}	{
						removeNode(&(def_array), yytext);
						BEGIN(INITIAL);
					}
					
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
							
							
							//check for cycles...
							for(int idx = 0; idx < currPtr; idx++){
								if(strcmp(name,filenameStack[idx])==0){
									fprintf(stderr,"Include cycle detected ! %s name is in a cycle. Aborting\n",name);
									exit(1);
								}
							}
							
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

{TYPE} 	{prettyprint(currName,yylineno,0,yytext);}
{FOR}	{prettyprint(currName,yylineno,1,yytext);}
{WHILE}	{prettyprint(currName,yylineno,2,yytext);}
{DO}	{prettyprint(currName,yylineno,3,yytext);}
{IF}	{prettyprint(currName,yylineno,4,yytext);}
{ELSE}	{prettyprint(currName,yylineno,5,yytext);}
{BREAK}	{prettyprint(currName,yylineno,6,yytext);}
{CONTINUE}	{prettyprint(currName,yylineno,7,yytext);}
{RETURN}	{prettyprint(currName,yylineno,8,yytext);}

{IDENT}		{if(findIdentifier(&def_array,yytext) >= 0){
				//print the out 
				
				}else{
				prettyprint(currName,yylineno,9,yytext);
				}
			}

{INTCONST} 	{prettyprint(currName,yylineno,10,yytext);}
{REALCONST} 	{prettyprint(currName,yylineno,11,yytext);} // the current text is yytext
{STRCONST}    { processString(currName,yylineno,yytext); }				
			
			
{CHARCONST}	{processChar(currName,yylineno,yytext);}

{LPAR}		{prettyprint(currName,yylineno,14,yytext);}
{RPAR}		{prettyprint(currName,yylineno,15,yytext);}
{LBRACKET}	{prettyprint(currName,yylineno,16,yytext);}
{RBRACKET}	{prettyprint(currName,yylineno,17,yytext);}
{LBRACE}	{prettyprint(currName,yylineno,18,yytext);}
{RBRACE}	{prettyprint(currName,yylineno,19,yytext);}

{COMMA}	{prettyprint(currName,yylineno,20,yytext);}
{SEMI}	{prettyprint(currName,yylineno,21,yytext);}
{QUEST}	{prettyprint(currName,yylineno,22,yytext);}
{COLON}	{prettyprint(currName,yylineno,23,yytext);}

{EQUALS}	{prettyprint(currName,yylineno,24,yytext);}
{NEQUAL}	{prettyprint(currName,yylineno,25,yytext);}
{GT}	{prettyprint(currName,yylineno,26,yytext);}
{GE}	{prettyprint(currName,yylineno,27,yytext);}
{LT}	{prettyprint(currName,yylineno,28,yytext);}
{LE}	{prettyprint(currName,yylineno,29,yytext);}
{ASSIGN}	{prettyprint(currName,yylineno,30,yytext);}
{INCR}	{prettyprint(currName,yylineno,31,yytext);}
{DECR}	{prettyprint(currName,yylineno,32,yytext);}
{PLUS}	{prettyprint(currName,yylineno,33,yytext);}
{MINUS}	{prettyprint(currName,yylineno,34,yytext);}
{STAR}	{prettyprint(currName,yylineno,35,yytext);}
{SLASH}	{prettyprint(currName,yylineno,36,yytext);}
{MOD}	{prettyprint(currName,yylineno,37,yytext);}
{TILDE}	{prettyprint(currName,yylineno,38,yytext);}
{PIPE}	{prettyprint(currName,yylineno,39,yytext);}
{AMP}	{prettyprint(currName,yylineno,40,yytext);}
{BANG}	{prettyprint(currName,yylineno,41,yytext);}
{DPIPE}	{prettyprint(currName,yylineno,42,yytext);}
{DAMP}	{prettyprint(currName,yylineno,43,yytext);}

[ \t]* /* discard white*/
\n 	{yylineno++;}


<<EOF>> 	{if(debug){
					printf("File %s is over! Line total : %d\n",currName,yylineno);
				}
			yylineno = 0;
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
			
[.^\n]	{fprintf(stderr,"File %s Line %d Unexpected token \'%s\'\n",currName,yylineno,yytext);}

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



