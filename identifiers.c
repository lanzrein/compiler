#include "identifiers.h"

#include <string.h>
#include <stdio.h>
#include <stdlib.h>




void ident_decl(identifier* id, char* name,int lineDecl,char* filename,enum types type){
	//~ id = malloc(sizeof(identifier));
	if(!id){
		fprintf(stderr,"Error : no more memory\n");
		return;
	}
	id->lineDecl = lineDecl;
	id->type = type;
	id->name = malloc(strlen(name));
	if(!id->name){
		fprintf(stderr,"Error : no more memory\n");
		return;
	}
	strcpy(id->name,name);
	id->filename = malloc(strlen(filename));
	if(!id->filename){
		fprintf(stderr, "Error no memory\n");
		return;
	}
	strcpy(id->filename,filename);
	
	return ;
}



void ident_free(identifier* id){
	free(id->name);
	free(id);
	return;
}

//check if same. 
int ident_compare(identifier* id1, identifier* id2){
		if(!id1 || !id2){
			return 1;
		}
		return strcmp(id1->name,id2->name);//0 if equal
	
}

/****Functions for list ***********/
void init_id_list(id_list* il){
	il = malloc(sizeof(id_list));
	il->size = 0;
	return;
	
}

//add ids 
void add_id(id_list* il, identifier* id){
	int size = il->size;
	for(int i = 0; i < size; i++){
		if(!ident_compare(&il->ids[i],id)){
			fprintf(stderr, "Error type check : identifier %s already declared line %d\n",il->ids[i].name,il->ids[i].lineDecl);
			return;
		}	
			 
	}
	
	//add id. 
	identifier* cpy = malloc(sizeof(identifier));;
	ident_decl(cpy,id->name,id->lineDecl,id->filename,id->type);
	
		//prepare some memory for the new array. 
	identifier* newArray;
	newArray = realloc(il->ids, (size+1)*sizeof(identifier));
	if(!newArray){
		fprintf(stderr,"Error : no more memory!\n");
		return;
	}
	
	//successful nbow add it. 
	newArray[size] = *cpy;
	il->ids = newArray;
	il->size++;
	return;
	
	
}

//-1 - identifier not declared
// 1 - identifier declared and matching type
// 0 mismatch error. 
// searches if an identifier exists AND if it matches the type 
int check_for_identifier(id_list* il, char* name, enum types expectedType){
		int size = il->size;
		for(int i = 0; i < size; i++){
			identifier id = il->ids[i];
			if(!strcmp(id.name,name)){
				//if they match
				//we want to have matching type
				return id.type == expectedType;
				
			}
		}
		
		return -1;
}



void delete_id_list(id_list* il){
	for(int i = 0; i < il->size;i++){
		free(&il->ids[i]);
	}
	free(il->ids);
	
	free(il);
	return;
}
