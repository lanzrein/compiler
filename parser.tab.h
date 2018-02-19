/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    TYPE = 258,
    FOR = 259,
    WHILE = 260,
    DO = 261,
    IF = 262,
    NOTELSE = 263,
    ELSE = 264,
    BREAK = 265,
    CONTINUE = 266,
    RETURN = 267,
    IDENT = 268,
    INTCONST = 269,
    REALCONST = 270,
    STRCONST = 271,
    CHARCONST = 272,
    LBRACE = 273,
    RBRACE = 274,
    SEMI = 275,
    COMMA = 276,
    ASSIGN = 277,
    QUEST = 278,
    COLON = 279,
    QUESTCOLON = 280,
    DPIPE = 281,
    DAMP = 282,
    PIPE = 283,
    AMP = 284,
    EQUALS = 285,
    NEQUAL = 286,
    GT = 287,
    GE = 288,
    LT = 289,
    LE = 290,
    PLUS = 291,
    MINUS = 292,
    STAR = 293,
    SLASH = 294,
    MOD = 295,
    BANG = 296,
    TILDE = 297,
    DECR = 298,
    INCR = 299,
    UAMP = 300,
    UMINUS = 301,
    PARTYPE = 302,
    LPAR = 303,
    RPAR = 304,
    LBRACKET = 305,
    RBRACKET = 306
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
