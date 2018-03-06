#pragma once

//header file for functions. 
#include "tokens.h"
#include "identifiers.h"


#include <stdio.h>
//Data structure for Functions. 

/**
 * @struct function carries information about functions
 * @param name the name of the function
 * @param argc the argument count of the function >=0 
 * @param lineDecl the line where the function is first declared
 * @param filename the name of the file where the function is declared
 * @param arguments the arguments stored as identifier
 * @param returnType the return type of the function 
 * */
typedef struct{
	char* name;
	size_t argc;
	int lineDecl;
	char* filename;
	identifier* arguments;
	enum types returnType;
}function;
/**
 * @struct a list to hold function
 * @param size the size of the list
 * @param functions a pointer to the list of functions. 
 * */
typedef struct {
	size_t size;
	function* functions;
}func_list;
/**
 * @brief creates a new function and stores it in a pointer
 * @param f the function created
 * @param args the arguments of the function
 * @param argc the argument count 
 * @param name the name of the function 
 * @param lineDecl the line where the funciton is declared
 * @param filename the file name of the funciton
 * */
void create_function(function* f,identifier* args,size_t argc,char* name,int lineDecl,char* filenames);
/**
 * @brief adds a return type to a function
 * @param f the function which we add a return type to 
 * @param returnType the return type to bre added
 * */
void add_return_type(function* f,enum types returnType);
/**
 * @brief check if the return type is the one expected
 * @param f the function that is matched
 * @param given the type expected
 * @return 1 if the types matches, 0 else 
 * */
int check_return_type(function* f, enum types given);
/**
 * @brief free the data of the funciton
 * @param f the function to free
 * */
void free_function(function* f);
/**
 * @brief compares two function to see if they mare identical
 * @param f1 the first functiojn
 * @param f2 the second one
 * @return 0 if they match,  != 0 else
 * */
int functions_equals(function* f1, function* f2);
/****************LIST METHOD ****************/
/**
 * @brief initializes a list 
 * @param fl the function list to initialize
 * */
void init_list(func_list* fl);
/**
 * @brief chekcs if a function is in the function list. 
 * @param fl the function list to search from 
 * @param f the function to search for
 * @return the idx of the function in fl if successful. <0 else.
 * */ 
int check_if_exists(func_list* fl,function* f);
/**
 * @brief tries to add a function to the function list
 * @param fl the list to add it to
 * @param f the function to add 
 * */
void add_function(func_list* fl, function* f);
/**
 * @brief copy a function. 
 * @param copy the new function 
 * @param orig the original function 
 * */
void copyfunc(function* copy,function* orig);
/**
 * @brief clear all data of the function list
 * @param fl the function list to clear 
 * */ 
void clear_func_list(func_list* fl);

