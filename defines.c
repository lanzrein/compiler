/**
 * @file defines.c 
 * @brief a file that holds data structures and method to help with the parsing of defines
 * */
#include "defines.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>


   /**
  * @brief allocates memory for a define
  * @param def the define to allocate
  * @param identifier the identifier of the define
  * @param text the text of the define
  * @return 0 success < 0 on error */
 int allocDefine(define* def, char* identifier, char* text){
	if(def == NULL){
		return -1;
	}
	def->identifier = malloc(strlen(identifier)+1);
	strcpy(def->identifier,identifier);
	def->arbitraryText = malloc(strlen(text)+1);
	strcpy(def->arbitraryText,text);
	
	if(def->arbitraryText == NULL || def->identifier == NULL){
		return -1;
	}
	
		return 0;
	 
	 
 };

 /**
  * @brief frees the memory of a pointer on a define
  * @param def the define to free
  * */
 void freeDefine(define* def){
		free(def->identifier);
		free(def->arbitraryText);
		free(def);
		return;
	 
 };

 /**
  * @brief compares the identifier with a define. 
  * @param def1 first define
  * @param identifier 
  * @return 0 if the identifier is the same. != 0 else */
 int compareDefs(define* def1, char* identifier){
	 if(def1->identifier != NULL){
		return strcmp(def1->identifier,identifier);
	}
		return -1;
 };
 
 
 /**
  * @brief init initializes the def_arr. 
  * @param def_ar the array to initialize
  * */
 void initArray(define_array* def_arr){

	if(!def_arr){
		fprintf(stderr,"Error no mem\n");	
		return ;
	}
	def_arr->size = 0;
	def_arr->array = NULL;
}
 
 
  /**
  * @brief add a define to our list. 
  * @param the head 
  * @param def the define to add
  * */
 void addNode(define_array* def_arr, define* def){
	int idx = def_arr->size;
	if(idx == MAX_DEFINES){
		fprintf(stderr, "Error, reached max define's number.\n");
		return;
	}
	
	for(int i = 0; i < def_arr->size; i++){
		//check for cycles..
		if(cycleCheck(&def_arr->array[i], def)){
			fprintf(stderr, "Error cycle detected\n");
			exit(1);
		}
		//check if alreadydefined. 
		if(strcmp(def_arr->array[i].identifier, def->identifier) == 0){
			fprintf(stderr, "Error identifier already defined\n");
			return;
		}
	}
	
	
	//else create the node and get add it. 
	
	define* copy;
	copy = malloc(sizeof(define));
	allocDefine(copy,def->identifier,def->arbitraryText);

	define* newArray;
	newArray = realloc(def_arr->array, (idx+1)*sizeof(define));
	if(!newArray){
		fprintf(stderr, "Error out of memory\n");
		return;
	}
	newArray[idx] = *copy;
	def_arr->array = newArray;
	def_arr->size++;
	return;
	 
	 
  };
  
 /**
  * @brief removes the define from the list. 
  * @param head pointer to the head
  * @param def the define to remove 
  * */
 void removeNode(define_array* def_arr, char* identifier){
	 

	size_t newSize = def_arr->size -1;
	define* newArray;
	newArray = malloc(newSize*sizeof(define));
	
	if(!newArray){
		fprintf(stderr, "Error no memory\n");
		return;
	}
	
	int offset = 0;
	for(int i = 0; i < def_arr->size ;i++){
		 if(strcmp(identifier,def_arr->array[i].identifier) != 0){
			newArray[i+offset] = def_arr->array[i];
		 }else{
			 offset = -1;
		 }
	 }
	 
	 def_arr->array = newArray;
	 def_arr->size--;
	 
	 return;
	  
 }
 
 
 
   /**
   * @brief tries to match an identifier to the one we have defined. 
   * @param der_arr the define array to search from
   * @param identifier the identifier to match
   * @param the index of the identifier if there is a match ; <0 else. 
   * */
int findIdentifier(define_array* def_arr, char* identifier){
	 for(int i = 0; i < def_arr->size; i++){
		if(compareDefs(&def_arr->array[i] , identifier) ==0){
			return i;
			
		}
		 
	 }
	 
		return -1;
	 
	 
 }

 /**
  * @brief check for a cycle between two define !!!! ONLY BASIC CYCLES
  * @param def1 
  * @param def2 
  * @return 1 if cycle, 0 else
  * */
 int cycleCheck(define* def1, define* def2){
	 char* ident1 = def1->identifier;
	 char* ident2 = def2->identifier;
	 char* text1 = def1->arbitraryText;
	 char* text2 = def2->arbitraryText;
	 
	 if(strstr(text2,ident1) != NULL && strstr(text1,ident2) != NULL){
		 return 1;
	 }
	 
		return 0;
	 
	 
 }

 
 /**
  * @brief frees all resources belonging to the define array
  * @param def_arr the array to be freed
  * */
  void freeAll(define_array* def_arr){
	  free(def_arr->array);
	  free(def_arr);
	  return;
  }
 
 
 
