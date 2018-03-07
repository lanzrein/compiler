/**
 * @file identifier.c 
 * @brief a file holding methods to help process identifiers
 * @author johan Lanzrein
 * */

#include "identifiers.h"

#include <string.h>
#include <stdio.h>
#include <stdlib.h>



/**
 * @brief declares a new identifier which is returned as a pointer. 
 * @param id the identifier to be declared
 * @param name the name of the identifier 
 * @param lineDecl line where it is declared
 * @param the filename where it was declared
 * @param type the type of the identifier
 * */
void ident_decl(identifier* id, char* name,int lineDecl,char* filename,enum types type){

	if(!id){
		fprintf(stderr,"Error : no more memory\n");
		return;
	}
	id->lineDecl = lineDecl;
	id->type = type;
	id->name = malloc(strlen(name)+1);
	if(!id->name){
		fprintf(stderr,"Error : no more memory\n");
		return;
	}
	strcpy(id->name,name);
	id->filename = malloc(strlen(filename)+1);
	if(!id->filename){
		fprintf(stderr, "Error no memory\n");
		return;
	}
	strcpy(id->filename,filename);
	
	return ;
}

/**
 * @brief frees the resources of the identifier
 * @param id the identifier to free
 * */
void ident_free(identifier* id){
	free(id->name);
	free(id);
	return;
}

/**
 * @brief compares two identifiers
 * @param id1 the first id
 * @param id2 the second id
 * @return 0 if identifier are equal != else
 * */
int ident_compare(identifier* id1, identifier* id2){
		if(!id1 || !id2){
			return 1;
		}
		return strcmp(id1->name,id2->name);//0 if equal
	
}

/****Functions for list *********************************/
/**
 * @brief initializes a list of identifier
 * @param il the identifier list to initialize
 * */
void init_id_list(id_list* il){
	il->ids = malloc(sizeof(identifier));
	il->size = 0;
	return;
	
}

/**
 * @brief adds the identifier id to the list 
 * @param il the list where we add the identifier
 * @param id the identifier
 * */
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

/**
 * @brief search if an identifier that matches the name and type exists
 * @param il the list where to search
 * @param name the name we want to have
 * @param expectedType the type we are looking for
 * @return -1 if identifier not declared, 1 if match in name and type, 0 if mismatch of type. 
 * */
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


/**
 * @brief delete the id list and clear it
 * @param il the list to clear
 * */
void delete_id_list(id_list* il){
	if(il == NULL){
		return;
	}
	
	

	il->size = 0;
	free(il);
	return;
}
