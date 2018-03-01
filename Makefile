LEX=flex
CC=gcc
CFLAGS+= -std=c99 -Wall -g
LDFLAGS+= -lfl

all: compile clean

compile: lex.yy.c parser.c tokens.o defines.o node.o functions.o identifiers.o
	gcc $(CFLAGS) -o parser parser.tab.c lex.yy.c tokens.o defines.o node.o functions.o identifiers.o $(LDFLAGS)

parser.c: parser.y node.o
	bison -v -d parser.y

lex.yy.c: lexer.l
	flex lexer.l

clean:
	rm -rf *.o lex.yy.c parser.tab.* 
