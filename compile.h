/**
 * File containing the method for generating the code. 
 * */

#include <node.h>

//Setup the compiler - give the file name to open
FILE* output_file
int setup_compiler(char* output_name);
//Finish up the compiler and write the file to system
void close_compiler();

//GetChar and put char 

void write_getchar();

void write_putchar();

//For relational operations

void rel_op(node* expr_1, node* expr_2, char rel_op);


//For arithmetic op

void arithm_op(node* expr_1, node* expr_2, int arit_op);

//For logical and
//need to have short circuiting
void logic_and(node* expr_1, node* expr_2);


//For logical or
void logic_or(node* expr_1, node* expr_2);

//If control flow

void if_control(node* boolean, node* statement1);
//If then else 

void if_then_else(node* boolean, node* statement1, node* statement2);

//For

void for_loop(node* init, node* condition, node* step, node* statement);
 
//While

void while_loop(node* boolean, node* statement);

//Do while

void do_while_loop(node* boolean, node* statement);

//Function call

void function_call(char* function_name, int argc);
//Assignements

void assignement(node* assigned, node* assignement);

//Function definitions


//Statement list. 
void statement_list(node* xs, node* new_statement);


void global_decl(node* expression);
