#include "functions.h"
#include "identifiers.h"

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

/**
 * @brief creates a new function and stores it in a pointer
 * @param f the function created
 * @param args the arguments of the function
 * @param argc the argument count 
 * @param name the name of the function 
 * @param lineDecl the line where the funciton is declared
 * @param filename the file name of the funciton
 * */
void create_function(function* f,identifier* args,size_t argc,char* name,int lineDecl,char* filename){

		if(!f){
			fprintf(stderr,"Error :function is null!\n");
			return;
		}
		
		f->arguments = malloc(sizeof(identifier)*argc);
		if(!f->arguments){
			fprintf(stderr,"Error : no more memory!\n");
			return;
		}
		f->argc = argc;
		f->lineDecl = lineDecl;
		memcpy(f->arguments,args,sizeof(identifier)*argc);
		f->name = malloc(strlen(name)+1);
		if(!f->name){
			fprintf(stderr,"Error : no more memory!\n");
			return;
		}
		
		strcpy(f->name,name);
		f->filename = malloc(strlen(filename)+1);
		if(!f->filename){
			fprintf(stderr,"Error : no more memory!\n");
			return;
		}
		strcpy(f->filename,filename);
		return ;
	
}
/**
 * @brief adds a return type to a function
 * @param f the function which we add a return type to 
 * @param returnType the return type to bre added
 * */
void add_return_type(function* f,enum types returnType){
	if(f->returnType){
		fprintf(stderr,"Type checking error : return type already defined !\n");
		 return;
	}
	
	f->returnType = returnType;
	return;
	
}
/**
 * @brief check if the return type is the one expected
 * @param f the function that is matched
 * @param given the type expected
 * @return 1 if the types matches, 0 else 
 * */
int check_return_type(function* f, enum types given){
	
	return f->returnType == given;
}

/**
 * @brief free the data of the funciton
 * @param f the function to free
 * */
void free_function(function* f){
	free(f->arguments);
	free(f->name);
	free(f);
	return;
}

/**
 * @brief compares two function to see if they mare identical
 * @param f1 the first functiojn
 * @param f2 the second one
 * @return 0 if they match,  != 0 else
 * */
int functions_equals(function* f1, function* f2){
	if(!strcmp(f1->name,f2->name) && f1->argc==f2->argc){
		//name is the same. and same argc ! 
		if(f1->returnType == f2->returnType){
			//same return type!
			//need to check if they are the same arg types.
			for(int i = 0; i < f1->argc; i++){
				if(f1->arguments[i].type != f2->arguments[i].type){
					//if any argument is different type 
					return 1;
				}
			}
			//we havent returned anything so they match 
			return 0;
		}
		
	}
	
	//not the same. 
	return 1;
}

/**
 * @brief initializes a list 
 * @param fl the function list to initialize
 * */
void init_list(func_list* fl){
	if(!fl){
		fprintf(stderr,"Error : Function list is null!\n");
		return;
	}
	fl->size = 0;
	fl->functions = malloc(sizeof(function));
	
}
/**
 * @brief chekcs if a function is in the function list. 
 * @param fl the function list to search from 
 * @param f the function to search for
 * @return the idx of the function in fl if successful. <0 else.
 * */ 
 int check_if_exists(func_list* fl,function* f){
	 if(!f || !fl){
		 return -1;
	 }
	for(int i = 0; i < fl->size;i++){
		if(0==functions_equals(&fl->functions[i],f)){
			return i;
		}
	}
	//no match found. 
	return -1;
}
/**
 * @brief add a function to the function list
 * @param fl the list to add it to
 * @param f the function to add 
 * */
void add_function(func_list* fl, function* f){
	//check if the function has already been declared. 
	if(!fl || !f){
		fprintf(stderr,"Error : function or function list has not been allocated\n");
		return;
	}
	int i = check_if_exists(fl,f);
	if(i > 0){
		fprintf(stderr,"Type checking error : function %s has already been declared line : %d\n",f->name,fl->functions[i].lineDecl);
		return;
	}
	//create a copy of the function and add it. 
	function* cpy = malloc(sizeof(function));
	if(!cpy){
		fprintf(stderr,"Error : no more memory!\n");
		return;
	}
	copyfunc(cpy,f);
	
	//prepare some memory for the new array. 
	int size = fl->size;
	function* newArray;
	newArray = realloc(fl->functions, (size+1)*sizeof(function));
	if(!newArray){
		fprintf(stderr,"Error : no more memory!\n");
		return;
	}
	
	//successful nbow add it. 
	newArray[size] = *cpy;
	fl->functions = newArray;
	fl->size++;
	return;
	
}
/**
 * @brief copy a function. 
 * @param copy the new function 
 * @param orig the original function 
 * */
void copyfunc(function* copy,function* orig){
	if(!orig || !copy){
		return;
	}
		
	
	
	copy->name = malloc(sizeof(strlen(orig->name)));
	strcpy(copy->name,orig->name);
	copy->returnType = orig->returnType;
	copy->argc = orig->argc;
	copy->arguments = malloc(copy->argc*sizeof(identifier));
	
	if(!copy->arguments || !copy->name){
		fprintf(stderr,"Error : no more memory!\n");
		return;
	}
	memcpy(copy->arguments,orig->arguments,copy->argc*sizeof(identifier));
	
	copy->lineDecl = orig->lineDecl;
	
	return;
	
}
/**
 * @brief clear all data of the function list
 * @param fl the function list to clear 
 * */ 
void clear_func_list(func_list* fl){
	
	free(fl->functions);
	
	free(fl);
	
}



