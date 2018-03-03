
#include "node.h"
#include "functions.h"

void setup_typecheck();
void enter_function(function* f);
void add_identifier_typechecking(identifier* id);
void add_function_typechecking(function* f);
void exit_function(function* f, enum types returnType);
void print_expression(node* n, char* filename, int lineno);
int to_char_type(node* n, node* left,node* right);
int cast(node* n, node* left, node* right);
int binary_op(node* n , node* left, node* right);
int brackets_op(node* n, node* left, node* right);
int return_type(char* function_name, enum types type);
int find_identifier(char* id_name, enum types expected_type);
int search_in(id_list* list, char* id_name, enum types expected_type);


int argument_match(char* function_name, int argc, enum types type[]);
void close_typecheck();
