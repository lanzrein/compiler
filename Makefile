LEX=flex
CC=gcc
CFLAGS+= -std=c99 -Wall -g
LDFLAGS+= -lfl

all: parser clean

parser: lex.yy.c parser.c tokens.o defines.o
	gcc $(CFLAGS) -o parser parser.tab.c lex.yy.c tokens.o defines.o $(LDFLAGS)

parser.c: parser.y
	bison -d parser.y

lex.yy.c: lexer.l
	flex lexer.l

clean:
	rm -rf *.o lex.yy.c 