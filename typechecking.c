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
int inFunction = 0;

void setup_typecheck(){
	//we need to initialize all of our typechecking variables. 
	create_node(root);
	init_id_list(identifier_global);
	init_list(function_list);
	
	
	
}

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

void add_identifier_typechecking(identifier* id){
	if(inFunction){
		//add to local scope
		add_id(identifier_local,id);
	}else{
		//add to global scope
		add_id(identifier_global,id);
		
	}
}

void add_function_typechecking(function* f){
	//simply add the function to func_list
	if(!f){
		fprintf(stderr,"Error : function f is null\n");
		return;
	}
	
	add_function(function_list,f);
	return;
	
}

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
 
 
 void print_expression(node* n, char* filename, int lineno){
	 if(!n || !filename){
		fprintf(stderr,"Error : node or filename not defined\n");
		return;
	 }
	 printf("Expression at file %s line %d has type %s\n",filename, lineno,typeTranslation[n->type]);
	 return;
	 
	 
 }
 /**
  * @brief for the operation that convert to char (==,!= .....)
  * ALSO TAKES BANG ???
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
 
 //left is the casting to. 
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
 //other binary operations + maybe unary that conserve type. 
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
	
	//return 1 in case of match, -1 in case of mis match. 
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
 //check if the identifier is declared
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
 
 //check in a list of identifier if it exists and type match. 
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
 //check if function is declared AND if the arg matches. 
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


void close_typecheck(){
	delete_tree(root);
	clear_func_list(function_list);
	delete_id_list(identifier_local);
	delete_id_list(identifier_global);
}
