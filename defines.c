/*
 * defines.c
 * 
 * Copyright 2018 johan <johan@LAPTOP-1SRG13AD>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 * 
 * 
 */
#include "defines.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>



 int allocDefine(define* def, char* identifier, char* text){
	if(def == NULL){
		return -1;
	}
	def->identifier = malloc(strlen(identifier)+1);
	strcpy(def->identifier,identifier);
	def->identifier[strlen(identifier)] = '\0';
	def->arbitraryText = malloc(strlen(text)+1);
	strcpy(def->arbitraryText,text);
	def->arbitraryText[strlen(text)] = '\0';
	
	if(def->arbitraryText == NULL || def->identifier == NULL){
		return -1;
	}
	
		return 0;
	 
	 
 };
 
 void freeDefine(define* def){
		free(def->identifier);
		free(def->arbitraryText);
		free(def);
		return;
	 
 };
 
 int compareDefs(define* def1, char* identifier){
	 if(def1->identifier != NULL){
		return strcmp(def1->identifier,identifier);
	}
		return -1;
 };
 
 
 
 
  /**
  * @brief add a define to our list. 
  * @param the head 
  * @param def the define to add
  * */
 void addNode(define_array* def_arr, define* def){
	
	
	
	int idx = def_arr->cursor;
	if(idx == MAX_DEFINES){
		fprintf(stderr, "Error, reached max define's number.\n");
		return;
	}
	
	for(int i = 0; i < def_arr->allocatedDefs; i++){
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
	if(def != NULL){
		def_arr->array[idx] = *def;
		def_arr->allocatedDefs ++;
		//~ while(idx < MAX_DEFINES || (def_arr.array[idx] != NULL)){
			//~ //update the cursor
			//~ idx++;
		//~ }
		idx++;
		def_arr->cursor = idx;
		
	}
	return;
	 
	 
  };
 /**
  * @brief removes the define from the list. 
  * @param head pointer to the head
  * @param def the define to remove 
  * */
 void removeNode(define_array* def_arr, char* identifier){
	 int count = 0;
	 for(int i = 0; i < MAX_DEFINES || count < def_arr->allocatedDefs;i++){
		 //~ if(def_arr.array[i] != 0){
			 count++;
			 if(compareDefs(&def_arr->array[i],identifier) == 0){
				 //its the one. 
				 //~ def_ar.cursor = i;
				 memset(&def_arr->array[i],0, sizeof(define));
				 def_arr->allocatedDefs--;
				 break;
			 }
		 
		 //~ }
	 }
	  
 }
 
 
 
 
int   findIdentifier(define_array* def_arr, char* identifier){
	 for(int i = 0; i < def_arr->cursor; i++){
		if(compareDefs(&def_arr->array[i] , identifier) ==0){
			return i;
			
		}
		 
	 }
	 
		return -1;
	 
	 
 }


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

 
 
 
 
