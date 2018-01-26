LEX=flex
CC=gcc
CFLAGS+= -std=c99 -Wall -g
LDFLAGS+= -lfl

all: lexer clean

lexer: lex.yy.c tokens.o defines.o
	gcc $(CFLAGS) -o lexer lex.yy.c tokens.o defines.o $(LDFLAGS)

lex.yy.c: lexer.l
	flex lexer.l

clean:
	rm -rf *.o lex.yy.c
