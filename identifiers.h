/**
 * @file a header file for the identifiers
 * @author Johan Lanzrein 
 * */
#pragma once

#include "tokens.h"

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
/**
 * @struct identifier represents an identifier with a few attributes
 * @param type the type of the identifier
 * @param name the name of the identifier
 * @param lineDecl the line where the identifier was declared
 * @param filename the name of the file where it was declared
 * */
typedef struct {
	enum types type;
	char* name; 
	int lineDecl;
	char* filename;
}identifier;

/**
 * @struct id_list a list of identifier
 * @param size the current size of the list
 * @param ids the identifiers in the list
 * */
typedef struct{
	size_t size;
	identifier* ids;
}id_list;

/**
 * @brief declares a new identifier which is returned as a pointer. 
 * @param id the identifier to be declared
 * @param name the name of the identifier 
 * @param lineDecl line where it is declared
 * @param the filename where it was declared
 * @param type the type of the identifier
 * */
void ident_decl(identifier* id, char* name,int lineDecl,char* filename,enum types type);
/**
 * @brief frees the resources of the identifier
 * @param id the identifier to free
 * */
void ident_free(identifier* id);

/**
 * @brief compares two identifiers
 * @param id1 the first id
 * @param id2 the second id
 * @return 0 if identifier are equal != else
 * */
int ident_compare(identifier* id1, identifier* id2);


/************FUNCTIONS FOR LIST ***************/

/**
 * @brief initializes a list of identifier
 * @param il the identifier list to initialize
 * */
void init_id_list(id_list* il);
/**
 * @brief adds the identifier id to the list 
 * @param il the list where we add the identifier
 * @param id the identifier
 * */
void add_id(id_list* il, identifier* id);
/**
 * @brief search if an identifier that matches the name and type exists
 * @param il the list where to search
 * @param name the name we want to have
 * @param expectedType the type we are looking for
 * @return -1 if identifier not declared, 1 if match in name and type, 0 if mismatch of type. 
 * */
int check_for_identifier(id_list* il, char* name,enum types expectedType);
/**
 * @brief delete the id list and clear it
 * @param il the list to clear
 * */
void delete_id_list(id_list* il);
