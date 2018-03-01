#include "functions.h"

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

//TODO CHECK FOR MEMERROR 
void create_function(function* f,enum types* args,size_t argc,char* name,int lineDecl){
		f = malloc(sizeof(function));
		if(!f){
			fprintf(stderr,"Error : no more memory!\n");
			return;
		}
		
		f->arguments = malloc(sizeof(enum types)*argc);
		if(!f->arguments){
			fprintf(stderr,"Error : no more memory!\n");
			return;
		}
		f->argc = argc;
		f->lineDecl = lineDecl;
		memcpy(f->arguments,args,sizeof(enum types)*argc);
		f->name = malloc(strlen(name));
		if(!f->name){
			fprintf(stderr,"Error : no more memory!\n");
			return;
		}
		strcpy(f->name,name);
		return ;
	
}

void add_return_type(function* f,enum types returnType){
	if(f->returnType){
		fprintf(stderr,"Type checking error : return type already defined !\n");
		 return;
	}
	
	f->returnType = returnType;
	return;
	
}


void free_function(function* f){
	free(f->arguments);
	free(f->name);
	free(f);
	return;
}
//TODO modify if we want to have overload ! 


int functions_equals(function* f1, function* f2){
	//~ if(!strcmp(f1->name,f2->name) && f1->argc==f2->argc){
		//~ //name is the same. and same argc ! 
		//~ if(f1->returnType == f2->returnType){
			//~ //same return type!
			//~ //need to check if they are the same arg types. 
			//~ for(int i = 0; i < f1->argc; i++){
				//~ if(f1->arguments[i] != f2->arguments[i]){
					//~ //if any argument is different. 
					//~ //TODO change to match widening arguments.  
					//~ return 1;
				//~ }
			//~ }
		//~ }
		
	//~ }
	//~ //not the same. 
	//~ return 1;
	return strcmp(f1->name,f2->name);
}


void init_list(func_list* fl){
	fl = malloc(sizeof(func_list));
	if(!fl){
		fprintf(stderr,"Error : no more memory!\n");
		return;
	}
	fl->size = 0;
	
}
//check if the function already exists 1 if exists. 
int check_if_exists(func_list* fl,function* f){
	for(int i = 0; i < fl->size;i++){
		if(0==functions_equals(&fl->functions[i],f)){
			return i;
		}
	}
	//no match found. 
	return 0;
}

void add_function(func_list* fl, function* f){
	//check if the function has already been declared. 
	int i = check_if_exists(fl,f);
	if(i){
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

void copyfunc(function* copy,function* orig){
	if(!orig || !copy){
		return;
	}
		
	
	//~ copy = malloc(sizeof(function));
	
	copy->name = malloc(sizeof(strlen(orig->name)));
	strcpy(copy->name,orig->name);
	copy->returnType = orig->returnType;
	copy->argc = orig->argc;
	copy->arguments = malloc(copy->argc*sizeof(enum types));
	
	if(!copy->arguments || !copy->name){
		fprintf(stderr,"Error : no more memory!\n");
		return;
	}
	memcpy(copy->arguments,orig->arguments,copy->argc*sizeof(enum types));
	
	copy->lineDecl = orig->lineDecl;
	
	return;
	
}


void clear_func_list(func_list* fl){
	for(int i = 0; i < fl->size;i++){
		free_function(&fl->functions[i]);
		
	}
	
	free(fl);
	
}
