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


/**
 * @file tokens.c
 * @brief contains the keywords for our lexer
 * */
 

 /**
  * the message for the keywords.
  * So we can refer to them with the help of the enum refered in 
  * tokens.h
  * */
 const char * const TOKENS_MESSAGES[] = {
	 "TYPE","FOR","WHILE","DO","IF","ELSE",
	 "BREAK","CONTINUE","RETURN",//keywords
	 "IDENT",//identifier
	 "INTCONST","REALCONST","STRCONST","CHARCONST", //const
	 "LPAR","RPAR","LBRACKET","RBRACKET","LBRACE","RBRACE",//()[]{}
	 "COMMA","SEMI","QUEST","COLON"//punct,
	 "EQUALS","NEQUAL","GT","GE","LT","LE","ASSIGN","INCR","DECR", //gt,ge..
	 "PLUS","MINUS","STAR","SLASH","MOD","TILDE",//math
	 "PIPE","AMP","BANG","DPIPE","DAMP"//logic
};

/**
 * A map that corresponds the pattern to the token
 * */
const struct token_translate TOKENS_MAP[] = {
	 {"TYPE","(char)|(int)|(float)"},
	 {"FOR","(for)"},
	 {"WHILE","(while)"},
	 {"DO","(do)"},
	 {"IF","(if)"},
	 {"ELSE","(else)"},
	 {"BREAK","(break)"},
	 {"CONTINUE","(continue)"},
	 {"RETURN","(return)"},//keywords
	 
	 {"IDENT","[_a-zA-Z][_a-zA-Z0-9]*"},//not start with digit. 
	 
	 {"INTCONST","[0-9]*"},
	 {"REALCONST",""},
	 {"STRCONST","\"(\\.|[^\\\"])*\""},
	 {"CHARCONST","\'.\'"},
	  
	 {"LPAR","("},{"RPAR",")"},
	 {"LBRACKET","["},{"RBRACKET","]"},
	 {"LBRACE","{"},{"RBRACE","}"},//()[]{}
	 
	 {"COMMA",","},{"SEMI",";"},
	 {"QUEST","?"},{"COLON",":"},//punct,
	 
	 {"EQUALS","=="},{"NEQUAL","!="},
	 {"GT",">"},{"GE",">="},
	 {"LT","<"},{"LE","<="},
	 {"ASSIGN","="},{"INCR","++"},{"DECR","--"},//gt,ge..
	 {"PLUS","+"},{"MINUS","-"},{"STAR","*"},
	 {"SLASH","/"},{"MOD","%"},{"TILDE","~"},//math
	 {"PIPE","|",},{"AMP","&"},
	 {"BANG","!"},
	 {"DPIPE","||"},{"DAMP","&&"}//logic
};


