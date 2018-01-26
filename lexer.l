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
void setupInclude();


//this is for our parsing of include.
#define MAX_INCLUDE_DEPTH 1024
YY_BUFFER_STATE includes_stack[MAX_INCLUDE_DEPTH];
char* filenameStack[MAX_INCLUDE_DEPTH];
int linenoStack[MAX_INCLUDE_DEPTH];

char* currName;
int currPtr = 0;


//This is for our define parsing. 
char* identifier; 
char currentText[MAX_DEFINE_LENGTH]; 
define_array def_array = {0,0,};
#define MAX_DEFINE_DEPTH MAX_INCLUDE_DEPTH
YY_BUFFER_STATE initBuffer;
YY_BUFFER_STATE substitutionStack[MAX_DEFINE_DEPTH];
char* currSubstitution[MAX_DEFINE_LENGTH];
int substitutionPointer = -1;

//this is for ifdefs..
#define MAX_NESTING 1024
int ifdefPtr = 0;
int ifdef = 0;
int ifStack[MAX_NESTING];
int readingif = 0;



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
IFDEF #ifdef
IFNDEF #ifndef
ELSEDEF #else
ENDIF #endif



%x COMMENTSINGLE
%x COMMENTMULTI
%x INCLUDECND
%x DEFINECND
%x LFTEXT
%x UNDEFCND
%x IFCND
%x IFIGNORE

%%


{IFDEF}		{if(debug){printf("New ifdef encountered\n");}
				if(ifdefPtr>=MAX_NESTING){
					fprintf(stderr, "Error, reached maxed nesting. \n");
					exit(1);
				}
				//set our if up. 
				ifStack[ifdefPtr++] = readingif;
				ifdef  = 1;
				
				BEGIN(IFCND);
			}
{IFNDEF}	{if(debug){printf("New ifndef encountered\n");}
				if(ifdefPtr>=MAX_NESTING){
					fprintf(stderr, "Error, reached maxed nesting. \n");
					exit(1);
				}
				
				//set our if up. 
				ifdef  = -1;
				ifStack[ifdefPtr++] = readingif;

				BEGIN(IFCND);
			}
			
<IFCND>{IDENT}	{
					if(ifdef > 0){
						//ifdef
						if(debug){printf("Ident : %s\n",yytext);}
						if(findIdentifier(&def_array,yytext) >= 0){
							//ident is defined. 
							if(debug){printf("Ident is defined\n");}

							//we can read, but we set our flag as reading.
							readingif = 1;
							BEGIN(INITIAL);
						
						}else{
							//cant read we have to ignore until else or endif encountered
							if(debug){printf("Ident is not defined\n");}

							readingif = -1;
							BEGIN(IFIGNORE);
						}
					}else{
						//ifndef
						if(findIdentifier(&def_array,yytext) < 0){
							//ident is not defined. 
							//we can read, but we set our flag as reading.
							readingif = 1;
							BEGIN(INITIAL);
						
						}else{
							//cant read we have to ignore until else or endif encountered
							readingif = -1;
							BEGIN(IFIGNORE);
						}
					
					}

				}
				
<IFCND>"."		{fprintf(stderr, "Error expected Identifier\n");exit(1);}
<IFIGNORE>{IFDEF}	{if(debug){printf("IFDEF encountered while ignoring, Setting flags to -1\n");}
						ifStack[ifdefPtr++] = -1;
					}
<IFIGNORE>{IFNDEF}	{if(debug){printf("IFNDEF encountered while ignoring, Setting flags to -1\n");}
						ifStack[ifdefPtr++] = -1;
					}
<IFIGNORE>{ENDIF}	{if(debug){printf("Endif encoutered. Set all flags to 0 and start reading normally\n");}
						if(ifdefPtr == 0){
							readingif = 0;
							ifdef = 0;
							BEGIN(INITIAL);
						}else{
							ifdefPtr--;
							readingif = ifStack[ifdefPtr];
							ifdef = 0;
							if(readingif >= 0){
								BEGIN(INITIAL);
							}else{
								//continue to ignore..
								BEGIN(IFIGNORE);
							}
						
						}
					}
<IFIGNORE>{ELSEDEF}	{if(debug){printf("Else preprocess. Changing our flags\n");}
					 if(readingif > 0){
						//we were reading so we stop. 
						//SHOULD NOT HAPPEN
						readingif = -1;
						BEGIN(IFIGNORE);
					 }else{
						//start reading
						readingif = 1;
						BEGIN(INITIAL);
					 }
					 }
<IFIGNORE>\n	{yylineno++;}
<IFIGNORE>.		{/*ignore*/}


{ENDIF}		{if(readingif == 0){
				fprintf(stderr,"Error, endif encountered outside of an if\n");BEGIN(INITIAL);
				
				}else{
					if(ifdefPtr == 0){
						//no more ifs to read. 
						readingif = 0;
						ifdef = 0;
						BEGIN(INITIAL);
					}else{
						//pop the stack
						ifdefPtr--;
 
						readingif = ifStack[ifdefPtr];
						ifdef = 0;
						if(readingif >= 0){
							//read
							BEGIN(INITIAL);
						}else{
							//continue to ignore..
							BEGIN(IFIGNORE);
						}
				
					}
				}
			}
			
{ELSEDEF}	{if(readingif == 0){fprintf(stderr, "Error else preprocessing outside of if\n");BEGIN(INITIAL);}
				//we need to invert. so if we were reading stop else start
					if(readingif > 0){
						//we were reading. 
						readingif = -1;
						BEGIN(IFIGNORE);
					}else{
						//we were ignoring
						readingif = 1;
						BEGIN(INITIAL);
					}
				}


						
<IFCND>[ \t]* {/*ignore*/}			
<IFCND>.	{fprintf(stderr, "Error expected an identifier for the preprocessing of ifdef.\n");
			 BEGIN(INITIAL);
			 }
				
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
					
					
					
					
					allocDefine(newDef,identifier, currentText);
					//add it to the list
					addNode(&(def_array), newDef);
					memset(currentText,0,strlen(currentText));
					yylineno++;
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
							setupInclude();
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

{IDENT}		{	int ident = findIdentifier(&def_array,yytext);
				if(ident >= 0){
				if(debug){printf("Found matching ident for %s\n", yytext);
				}
				//print the out..
				if(substitutionPointer > MAX_DEFINE_DEPTH){
					fprintf(stderr, "Error, reached max define depth\n");
					BEGIN(INITIAL);
				}
				if(substitutionPointer < 0){
					substitutionPointer++;
					//we need to save the current file
					initBuffer = YY_CURRENT_BUFFER;
					//switch to buffer;
					YY_BUFFER_STATE curr = yy_scan_string(def_array.array[ident].arbitraryText);
					yy_switch_to_buffer(curr);
					
					
				}else{
					substitutionStack[substitutionPointer++] = YY_CURRENT_BUFFER;
					YY_BUFFER_STATE curr = yy_scan_string(def_array.array[ident].arbitraryText);
					yy_switch_to_buffer(curr);
				
				}
				
				
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


<<EOF>> 	{
				if(debug){
					printf("File %s is over! Line total : %d\n",currName,yylineno);
					printf("Pointer states : Sub %d , Files %d \n",substitutionPointer, currPtr);
				}
				
				//first check if defines are done.
				//if we are in a define parsing then pop the next one if there is one etc..
				if(substitutionPointer >= 0){
					substitutionPointer--;
					if(substitutionPointer < 0){
						//no more defines 
						yy_delete_buffer(YY_CURRENT_BUFFER);
						yy_switch_to_buffer(initBuffer);
				}else{
					//there is a define to continue to parse. 
					yy_delete_buffer(YY_CURRENT_BUFFER);
					yy_switch_to_buffer(substitutionStack[substitutionPointer]);
				}
				
			
			}else{
			
				//then verify if we are done scanning files. 	
				if(0==currPtr){
					//finished parsing all files ! 
					free(currName);
					
					yyterminate();
				}else{
					currPtr--;
					//buffer change
					yy_delete_buffer(YY_CURRENT_BUFFER);
					yy_switch_to_buffer(includes_stack[currPtr]);
					//name change.
					currName = realloc(currName,strlen(filenameStack[currPtr])+1);
					strcpy(currName,filenameStack[currPtr]);
					//get yylineno
					yylineno = linenoStack[currPtr];
					
				}
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



void setupInclude(){
	//check for max depth
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
							char* name = malloc(length+1);
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
								fprintf(stderr,"Could not open file : %s will continue to read from current file. \n",name);
								yy_switch_to_buffer(includes_stack[currPtr]);
								currPtr--;
								BEGIN(INITIAL);
							}
							//set the file name.
							filenameStack[currPtr-1] = malloc(strlen(currName)+1);
							strcpy(filenameStack[currPtr-1],currName);
							filenameStack[currPtr-1][strlen(currName)] = '\0';
							strcpy(currName,name);
							currName[length] = '\0';
							free(name);
							//save the lineno
							linenoStack[currPtr-1] = yylineno;
							yylineno = 1;
							
							
							yy_switch_to_buffer(yy_create_buffer(yyin,YY_BUF_SIZE));

}


