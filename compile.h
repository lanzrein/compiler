/**
 * File containing the method for generating the code. 
 * */
#include <stdlib.h>
#include "node.h"
#include "functions.h"


//Setup the compiler - give the file name to open
FILE* output_file;
/**
 * @brief sets up the compiler so it can start generating code. 
 * @param output_name the name of the output file without the extension
 * @return 0 if success <0 if error 
 * */
int setup_compiler(char* output_name);

/*
 * @brief finish up the compiler and write the file to system
 * */
void close_compiler();

/**
 * @brief write the getchar method to the file. 
 * */
void write_getchar();
/**
 * @brief write the putchar method to the file
 * */
void write_putchar();

/**
 * @brief writes the boolean operation to the file. also stores value on the boolean
 * @param boolean the result of operation
 * @param expr_1 left hand side of expression
 * @param expr_2 right hand side of expression
 * @param rel_op the operation done. 
 * */
void rel_op(node* boolean,node* expr_1, node* expr_2, char rel_op);


/**
 * @brief writes the arithmetic operation to the file. stores output value in expr
 * @param expr the result of operation
 * @param expr_1 left hand side of expression
 * @param expr_2 right hand side of expression
 * @param arit_op the operation done. 
 * */
void arithm_op(node* expr,node* expr_1, node* expr_2, int arit_op);

/**
 * @brief writes the logical and to the file,
 * @param expr_1 left hand side of expression
 * @param expr_2 right hand side of expresison
 * */
void logic_and(node* expr_1, node* expr_2);


/**
 * @brief writes the logical or to the file,
 * @param expr_1 left hand side of expression
 * @param expr_2 right hand side of expression
 * */
 void logic_or(node* expr_1, node* expr_2);

/**
 * @brief writes the if control flow to the file,
 * @param boolean condition for the if
 * @param statement statement1 statements inside the if
 * */
void if_control(node* boolean, node* statement1);

/**
 * @brief writes if then else control to the file
 * @param boolean condition for the if
 * @param statement1 the true part
 * @param statement2 the false part
 * */
void if_then_else(node* boolean, node* statement1, node* statement2);

//For
/**
 * @brief writes the for loop control flow to the file
 * @param init the initializing stateament
 * @param condition the condition to continue the loop
 * @param step the step statement
 * @param statement the statements inside the loop
 * */
void for_loop(node* init, node* condition, node* step, node* statement);
 
/**
 * @brief the while loop control flow to the file
 * @param boolean the condition for the loop to continue
 * @param statement the code in the loop
 * */
void while_loop(node* boolean, node* statement);

/**
 * @brief the do_while loop to the file
 * @param boolean the condition to continue
 * @param the statement in the loop
 * */
void do_while_loop(node* boolean, node* statement);

/**
 * @brief writes a function call to the file
 * @param function_name the name of the function
 * @param args the argument of the funciton
 * @param argc the number of arguemnts
 * */
void function_call(char* function_name,identifier*args, int argc);


/**
 * @brief writes the assignement code to the file
 * @param assigned the right hand side
 * @param assignement the left hand side
 * */
void assignement(node* assigned, node* assignement);

/**
 * 
 * @brief a list of statement, takes care of the nexts etc..
 * @param concate_state the concatenated statement
 * @param stat_1 the first statement
 * @param stat_2 the second statement
 * */
void statement_list(node* concate_state,node* stat_1, node* stat_2);

/**
 * @brief writes the global declaration to the file
 * @param expression the declaration to be written to the file
 * */
void global_decl(node* expression);


/**
 * @brief translates the type into a string that is compatible with the stack language
 * @param type the type coded in int
 * @return the string for the stack machine
 * */
char* type_to_char(int type);
