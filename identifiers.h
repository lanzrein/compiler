#include "tokens.h"

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct {
	enum types type;
	char* name; 
	int lineDecl;
}identifier;

typedef struct{
	size_t size;
	identifier* ids;
}id_list;

void ident_decl(identifier* id, char* name,int lineDecl,enum types type);
void ident_free(identifier* id);
int ident_compare(identifier* id1, identifier* id2);
void init_id_list(id_list* il);
void add_id(id_list* il, identifier* id);
int check_for_identifier(id_list* il, char* name,enum types expectedType);
void delete_id_list(id_list* il);
