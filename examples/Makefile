LEX=flex
CC=gcc
CFLAGS+= -std=c99 -Wall -g

all: lexer clean

lexer: lex.yy.c
	gcc $(CFLAGS) -o lexer lex.yy.c -lfl

lex.yy.c: sample1.l
	flex sample1.l

clean:
	rm -rf *.o lex.yy.c
