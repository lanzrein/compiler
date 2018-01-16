/* 
 * From : http://alumni.cs.ucr.edu/~lgao/teaching/flex/sample1.lex
 * Using it to learn a bit how to use flex.
 *
 *
 * Sample Scanner1: 
 * Description: Replace the string "username" from standard input 
 *              with the user's login name (e.g. lgao)
 * Usage: (1) $ flex sample1.lex
 *        (2) $ gcc lex.yy.c -lfl
 *        (3) $ ./a.out
 *            stdin> username
 *	      stdin> Ctrl-D
 * Question: What is the purpose of '%{' and '%}'?
 *           What else could be included in this section?
 */

%{
/* need this for the call to getlogin() below */
#include <unistd.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
%}

DIGIT [0-9]*
STRING \"(\\.|[^\\"])*\"

%%
"(" 	{printf("This is a right bracket\n");}
")" 	{printf("This is a left bracket\n");}
username	{if(getlogin()!=NULL)printf("%s\n", getlogin());}
{STRING}    {
				if(strlen(yytext) > 2){
					char* str = malloc(strlen(yytext)); 
					strncpy(str,yytext+1,strlen(yytext)-2);
					printf("String with value : %s\n",str);
					free(str);
				}else{
					printf("There is an emptry string\n");
				}
			}
				
{DIGIT}* 	{printf("This is a whole number : %d\n", atoi(yytext));}
{DIGIT}*+"."{DIGIT}* 	{printf("This is a REAL number : %f\n", atof(yytext));} // the current text is yytext
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
