/**Type checking file. */
#include "functions.h"
#include "identifiers.h"
#include "node.h"
#include "tokens.h"


//Global variable that are needed 
//To store functions, identifiers and a tree. 

node* root;
func_list* function_list;
id_list* identifier_list;

void setup_typecheck(){
	//we need to initialize all of our typechecking variables. 
	create_node(root);
	init_id_list(identifier_list);
	init_list(function_list);
	
	
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
		fprintf("Error : node or filename not defined\n");
		return;
	 }
	 printf("Expression at file %s line %d has type %s\n",filename, lineno,typeTranslation[n->type]};
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
	 n = malloc(sizeof(node))
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
	 
 }
	
	//return 1 in case of match, -1 in case of mis match. 
 int return_type(char* function_name, enum types type){
	 for(int i = 0; i < function_list->size; i++){
		 function f = function_list->functions;
		 if(0==strcmp(f.name, function_name)){
			 //name match. 
			 //TODO ASK TEACHER: 
			 return type == f.type;//0 if match != 0 else. 
		 }
	 }
 }
 //check if the identifier is declared
 int find_identifier(char* id_name, enum types expected_type){
	 for(int i = 0; i < identifier_list->size; i++){
		 identifier id = identifier_list->ids[i];
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
	 
		return -1; //identifier not declared. 
 }
 //check if function is declared AND if the arg matches. 
 int argument_match(char* function_name, int argc, enum types[] type){
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
					if(type[a] != f.type[a]){
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
	delete_id_list(identifier_list);
}
