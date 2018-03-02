/*
 * tokens.c
 * 
 * Copyright 2018 johan <johan@LAPTOP-1SRG13AD>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 * 
 * 
 */
 #include "tokens.h"
 #include <stdlib.h>
 #include <string.h>
 #include <stdio.h>
 

/**
 * @file tokens.c
 * @brief contains the keywords for our lexer and a few utility method to pretty print them 
 * */
 
 
 
  const char* typeTranslation[7]= { "NA", "char", "int", "float",
									"char[]","int[]","float[]"};
 

/**
 * @struct an array that contains the ID of all tokens. 
 * */
 const char * const TOKENS_MESSAGES[] = {
	 "TYPE","FOR","WHILE","DO","IF","ELSE",
	 "BREAK","CONTINUE","RETURN",//keywords
	 "IDENT",//identifier
	 "INTCONST","REALCONST","STRCONST","CHARCONST", //const
	 "LPAR","RPAR","LBRACKET","RBRACKET","LBRACE","RBRACE",//()[]{}
	 "COMMA","SEMI","QUEST","COLON",//punct,
	 "EQUALS","NEQUAL","GT","GE","LT","LE","ASSIGN","INCR","DECR", //gt,ge..
	 "PLUS","MINUS","STAR","SLASH","MOD","TILDE",//math
	 "PIPE","AMP","BANG","DPIPE","DAMP"//logic
};


/**
 * @brief pretty prints a token  
 * @param file the filename
 * @param lineno current line number
 * @param tokenIdx the index of the token according to our table. (TOKENS_MESSAGES)
 * @param text the content of the token
 * */
void prettyprint(char* file,int lineno, int tokenIdx, char* text){

	printf("File %s Line %d Token %s \'%s\'\n",file,lineno,TOKENS_MESSAGES[tokenIdx],text);	
}



/**
 * @brief processes a C-string and pretty prints it. 
 * @param file the filename
 * @param lineno current line number
 * @param string the string
 * */
void processString(char* file, int lineno, char* yytext){
				
				if(strlen(yytext) >= 2){
					char* str = malloc(strlen(yytext)-2+1); 
					strncpy(str,yytext+1,strlen(yytext)-2);
					str[strlen(yytext)-2]='\0';
					prettyprint(file,lineno,12,str);
					free(str);
				}else{
					fprintf(stderr, "Error encountered when parsing a token. \n");
				}
	
}

/**
 * @brief processes a char and pretty prints it. 
 * @param file the filename
 * @param lineno current line number
 * @param string a pointer to the char. 
 * */
void processChar(char* file, int lineno, char* yytext){
	
		printf("File %s Line %d Token %s \'%c\'\n",file,lineno,TOKENS_MESSAGES[13],yytext[1]);	

	
}

/**
 * NOT USED YET 
 * @brief this method allocates memory and creates a token
 * @param id the id
 * @param content the content of the token
 * @param tok (OUT) the token created
 * */
void createToken(char* id, char* content, token* tok){
	if(id == NULL || content == NULL){
		return;
	}
	
	tok = malloc(sizeof(token));
	tok->id = malloc(strlen(id));
	strcpy(tok->id,id);
	
	tok->content = malloc(strlen(content));
	strcpy(tok->content,content);
	
}

/**
 * NOT USED YET
 * @brief frees the memory used by a token
 * @param tok the token to free
 * */
void freeToken(token* tok){
	free(tok->id);
	free(tok->content);
	free(tok);
	return;
}

