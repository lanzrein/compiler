/**Type checking file. */
#include <stdio.h>
#include "functions.h"
#include "identifiers.h"
#include "typechecking.h"
#include "node.h"
#include "tokens.h"


//Global variable that are needed 
//To store functions, identifiers and a tree. 
node* root;
func_list* function_list;
id_list* identifier_global;
id_list* identifier_local;
//a flag to know if we are in a function or not. 
int inFunction = 0;
/**
 * @brief setup the typecheck system. 
 * */
void setup_typecheck(){
	//we need to initialize all of our typechecking variables. 
	create_node(root);
	init_id_list(identifier_global);
	init_list(function_list);
	
	
	
}
/**
 * @brief enter a function and setup the local identifiers 
 * @param f the fucntion to enter
 * */
void enter_function(function* f){
	//init the list of local identifier. 
	init_id_list(identifier_local);
	//add all the paramter to the identifier_local
	for(int i = 0; i < f->argc; i++){
		identifier p = f->arguments[i];
		add_id(identifier_local,&p);
	}
	//mark flag as in inFunction so we add the new identifier to local
	inFunction = 1;
}
/**
 * @brief add an identifier to the list of identifier ( automatically handles the scope ) 
 * @param id the identifier to be added the list 
 * */
void add_identifier_typechecking(identifier* id){
	if(inFunction){
		//add to local scope
		add_id(identifier_local,id);
	}else{
		//add to global scope
		add_id(identifier_global,id);
		
	}
}
/**
 * @brief add a function to the list of function in the typechecking 
 * @param f the function to add 
 * */
void add_function_typechecking(function* f){
	//simply add the function to func_list
	if(!f){
		fprintf(stderr,"Error : function f is null\n");
		return;
	}
	
	add_function(function_list,f);
	return;
	
}
/**
 * @brief exit the function and check if the return type matches
 * @param f the function to exit
 * @param returnType the return type we have
 * */
void exit_function(function* f, enum types returnType){
	//check for return type 
	if(f->returnType != returnType){
		
		//TODO error.
		fprintf(stderr, "Error typechecking got type %s expected type %s (func %s declared l. %d\n",
						typeTranslation[returnType],typeTranslation[f->returnType],f->name,f->lineDecl);
		return ;
	}
	//empty the funciton list. 
	delete_id_list(identifier_local);
	//
	inFunction = 0;
	return;
}
/**NEEDS : 
 * Print result of expression at file line etc. 
 * type mismatch checks
 * functions calls have correct parameters
 * return statement have correct type
 * undeclared variable and functions. 
 * ---> best effort. 
 * */
 
 /**
 * @brief pretty print an expression from the node
 * @param n the node 
 * @param filename the file where the expression is
 * @param lineno the line no where we found the expression
 * */
 void print_expression(node* n, char* filename, int lineno){
	 if(!n || !filename){
		fprintf(stderr,"Error : node or filename not defined\n");
		return;
	 }
	 printf("Expression at file %s line %d has type %s\n",filename, lineno,typeTranslation[n->type]);
	 return;
	 
	 
 }
/**
 * TODO what bout BANG 
 * @brief the operation where a node is converted to char 
 * @param n the node
 * @param left the left leaf node
 * @param right the righ tnode
 * @return 0 if it matches <0 if tehre is a mismatch 
 * */
 int to_char_type(node* n, node* left,node* right){
	 if(!left || !right){
		fprintf(stderr, "Error : either left or right node is not allocated\n");
		 return -3;
	 }
	 if(left->type != right->type){
		 return -1;//mismatch
	 } 
	  n = malloc(sizeof(node));
		n->type = CHAR;
		set_left(n,left);
		set_right(n,right);
		return 0;
 }
 
 /**
 * @brief operation where it is casted
 * @param the new node n
 * @param left the type where it will be casted to 
 * @param right the content that is casted 
 * @return 0 in success < 0 in error. 
 * */
 int cast(node* n, node* left, node* right){
	 if(!left || !right){
		 fprintf(stderr, "Error : either left or right node is not allocated\n");
		 return -3;
	 }
	 n = malloc(sizeof(node));
	 n->type = left->type;
	 set_left(n,left);
	 set_right(n,right);
	 set_attribute(n,right->attribute, right->sizeAttribute);
	 return 0;
 }
/**
 * @brief a binary operation is proceeeded
 * @param n the node containing the operand 
 * @param left the left hand side
 * @param right the right hand side
 * @return 0 in success < 0 in mismatch
 * */
 int binary_op(node* n , node* left, node* right){
	 //check if the type matches. 
	 if(!left || !right){
		 fprintf(stderr, "Error : either left or right node is not allocated\n");
		 return -3;
	 }
	 
	 n = malloc(sizeof(node));
	 if(left->type != right->type){
		return -1;//return 
	 }
	 
	 n->type = left->type;
	 
	 set_left(n,left);
	 set_right(n,right);
	 //TODO set attribute ????
	 return 0;
 }

	
/**
 * @brief an operation where we select from an array
 * @param n the node resulting
 * @param left the array from where we select
 * @param right the idx where we choose from
 * @return 0 in success <0 else
 * */
 int brackets_op(node* n, node* left, node* right){
	 if(!left || !right){
		 fprintf(stderr, "Error : either left or right node is not allocated\n");

		 return -3;
	 }
	 
	 if(left->type < CHARARR){
		 //we dont have an array !!!
		 return -1;//mismatch
	 }
	 
	 n = malloc(sizeof(node));
	 n->type = left->type - FLOAT;//check in tokens.h to see why. 
	 set_left(n,left);
	 set_right(n,right);
	 //TODO something else ???
	 return 0;
	 
 }
	
/**
 * @brief check if the function matches the expected return type 
 * @param function_name the name of the function
 * @param type the return type we expect
 * @return 1 in match, 0 in mismatch , <0 if no such fucntion
 * */
int return_type(char* function_name, enum types type){
	 for(int i = 0; i < function_list->size; i++){
		 function f = function_list->functions[i];
		 if(0==strcmp(f.name, function_name)){
			 //name match. 
			 //TODO ASK TEACHER: 
			 return type == f.returnType;//0 if match != 0 else. 
		 }
	 }
	return -1;//funciton undeclared. 
 }
 /**
 * @brief search for the identifier if it exists and if the match types
 * @param id_name the name of the identifier
 * @param expected_type the expected_type
 * @return 0 in success, -1 in not found, -2 if mismatch 
 * */
 int find_identifier(char* id_name, enum types expected_type){
		int local = search_in(identifier_local,id_name,expected_type);
		if(local == 0){
			return local;
		}else if(local == -2){
			//mismatch
			return -2;
		}
		
		return search_in(identifier_global,id_name,expected_type);
		
 }
 
 /**
 * @brief search in a list of identifier for a ident
 * @param list the list to search from 
 * @param id_name the id name
 * @param expected_type the expected type;
 * @return 0 in success, -1 in not found, -2 if mismatch 
 * */
 int search_in(id_list* list, char* id_name, enum types expected_type){
	 for(int i = 0; i < list->size; i++){
		 identifier id = list->ids[i];
		 if(0==strcmp(id_name,id.name)){
			 //name match
			if(expected_type == id.type){
				//match 
				return 0;
			}else{
				return -2;//type mismatch
			}
		 }
		 
	 }
		return -1;
	 
 }
 /**
 * @brief check if the argument match the expected types
 * @param function_name the name of the fucntion
 * @param argc the expected argument count
 * @param type[] an array of expected type. 
 * @return 0 in success, -2 in mismatch, -1 if the function does not exist
 * */ 
 int argument_match(char* function_name, int argc, enum types type[]){
	 int name_matches = 0;
	 for(int i = 0; i < function_list->size; i++){
		 function f = function_list->functions[i];
		 if(0==strcmp(f.name,function_name)){
			//name match 
			name_matches = 1;
			if(argc == f.argc){
				//correct argc. 
				int match = 1; 
				for(int a = 0; a < argc; a++){
					if(type[a] != f.arguments[a].type){
						//if any argument doesnt match we mark it as non match
						match=0;
					}
				}
				if(match){
					return 0;//its  match ! :) 
				}
			}
			
		 }
	 }
	 
	 if(name_matches){
		 return -2;//type mismatch. 
	 }else{
		 //function not declared. 
		 return -1;//not declared. 
	 }
 }

/**
 * @brief close up and free all resources for the typecheck system
 * */
void close_typecheck(){
	delete_tree(root);
	clear_func_list(function_list);
	delete_id_list(identifier_local);
	delete_id_list(identifier_global);
}
