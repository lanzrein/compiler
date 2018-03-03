#pragma once

//header file for functions. 
#include "tokens.h"
#include "identifiers.h"


#include <stdio.h>
//Data structure for Functions. 


typedef struct{
	char* name;
	size_t argc;
	int lineDecl;
	char* filename;
	identifier* arguments;
	enum types returnType;
}function;

typedef struct {
	size_t size;
	function* functions;
}func_list;
//TODO doc doc 

void create_function(function* f,identifier* args,size_t argc,char* name,int lineDecl,char* filenames);
void add_return_type(function* f,enum types returnType);
int check_return_type(function* f, enum types given);
void free_function(function* f);
int functions_equals(function* f1, function* f2);
void init_list(func_list* fl);
int check_if_exists(func_list* fl,function* f);
void add_function(func_list* fl, function* f);
void copyfunc(function* copy,function* orig);
void clear_func_list(func_list* fl);

