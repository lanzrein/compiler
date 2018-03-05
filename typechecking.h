/**
 * @file typechecking.h 
 * @author johan lanzrein
 * */
#include "node.h"
#include "functions.h"
/**
 * @brief setup the typecheck system. 
 * */
void setup_typecheck();
/**
 * @brief enter a function and setup the local identifiers 
 * @param f the fucntion to enter
 * */
void enter_function(function* f);
/**
 * @brief add an identifier to the list of identifier ( automatically handles the scope ) 
 * @param id the identifier to be added the list 
 * */
void add_identifier_typechecking(identifier* id);
/**
 * @brief add a function to the list of function in the typechecking 
 * @param f the function to add 
 * */
void add_function_typechecking(function* f);
/**
 * @brief exit the function and check if the return type matches
 * @param f the function to exit
 * @param returnType the return type we have
 * */
void exit_function(function* f, enum types returnType);
/**
 * @brief pretty print an expression from the node
 * @param n the node 
 * @param filename the file where the expression is
 * @param lineno the line no where we found the expression
 * */
void print_expression(node* n, char* filename, int lineno);
/**
 * @brief the operation where a node is converted to char 
 * @param n the node
 * @param left the left leaf node
 * @param right the righ tnode
 * @return 0 if it matches <0 if tehre is a mismatch 
 * */
int to_char_type(node* n, node* left,node* right);
/**
 * @brief operation where it is casted
 * @param the new node n
 * @param left the type where it will be casted to 
 * @param right the content that is casted 
 * @return 0 in success < 0 in error. 
 * */
int cast(node* n, node* left, node* right);
/**
 * @brief a binary operation is proceeeded
 * @param n the node containing the operand 
 * @param left the left hand side
 * @param right the right hand side
 * @return 0 in success < 0 in mismatch
 * */
int binary_op(node* n , node* left, node* right,void* operand);

/**
 * @brief an operation where we select from an array
 * @param n the node resulting
 * @param left the array from where we select
 * @param right the idx where we choose from
 * @return 0 in success <0 else
 * */
int brackets_op(node* n, node* left, node* right);
/**
 * @brief check if the function matches the expected return type 
 * @param function_name the name of the function
 * @param type the return type we expect
 * @return 1 in match, 0 in mismatch , <0 if no such fucntion
 * */
int return_type(char* function_name, enum types type);
/**
 * @brief search for the identifier if it exists and if the match types
 * @param id_name the name of the identifier
 * @param expected_type the expected_type
 * @return 0 in success, -1 in not found, -2 if mismatch 
 * */
enum types find_identifier(char* id_name);
/**
 * @brief search in a list of identifier for a ident
 * @param list the list to search from 
 * @param id_name the id name
 * @param expected_type the expected type;
 * @return 0 in success, -1 in not found, -2 if mismatch 
 * */
enum types search_in(id_list* list, char* id_name);
/**
 * @brief check if the argument match the expected types
 * @param function_name the name of the fucntion
 * @param argc the expected argument count
 * @param type[] an array of expected type. 
 * @return return type in success, -2 in mismatch, -1 if the function does not exist
 * */
int argument_match(char* function_name, int argc, id_list* ids);
/**
 * @brief close up and free all resources for the typecheck system
 * */
void close_typecheck();
