/**
 * File containing the method for generating the code. 
 * */

#include "node.h"
#include "typechecking.h"
#include "tokens.h"
#include "compile.h"
//the root of the syntax tree
extern node* root;
//the funciton list used for symbol table
extern func_list* function_list;
//list of global identifiers
extern id_list* identifier_global;
//list of local identifier
extern id_list* identifier_local;
//the line number
extern int yylineno;

//Setup the compiler - give the file name to open
FILE* output_file;
char filename[512];
/**
 * @brief sets up the compiler so it can start generating code. 
 * @param output_name the name of the output file without the extension
 * @return 0 if success <0 if error 
 * */
int setup_compiler(char* output_name){
	//we create a file and open it. 
	char name[strlen(output_name)+2];
	strcpy(name, output_name);
	strcpy(filename,output_name);
	name[strlen(output_name)] = '.';
	name[strlen(output_name)+1] = 'j';
	strcpy(filename,name);
	output_file = fopen(name,"w");
	if(!output_file){
		fprintf(stderr, "Error could not open file : ");
		perror(NULL);
		return -1;
	}
		//we need to write the basic introduction
		
		char class[512];
		sprintf(class,".class public %s\n.super java/lang/Object\n\n",output_name);
		fwrite(class,1,strlen(class),output_file);
		return 0;
	
	
}
/*
 * @brief finish up the compiler and write the file to system
 * */
void close_compiler(){
	char* end = "\n.end class\n";
	fwrite(end,1,strlen(end),output_file);

	fflush(output_file);//force to write
	fclose(output_file);
	//free what is necessary...

	return ;
	
}

/**
 * @brief write the getchar method to the file. 
 * */
void write_getchar(){
	char* get_char = 
		".method public static getChar : ()I \n\t.code stack 1 locals 1\n\tgetstatic Field java/lang/System in Ljava/io/PrintStream;\n\tinvokevirtual Method java/io/InputStream read ()I\n\tistore_0 \n\tiload_0\n\tireturn \n\n\t.end code\n.end method\n";

	fwrite(get_char,1,strlen(get_char),output_file);
	
	return;
}
/**
 * @brief write the putchar method to the file
 * */
void write_putchar(){
	char* put_char = 
		".method public static putChar : (I)I;\n\t.code stack 2 locals 1\n\tgetstatic Field java/lang/System out Ljava/io/PrintStream;\n\tiload_0\n\tinvokevirtual Method java/io/PrintStream print (I)V\n\tiload_0\n\tireturn\n\n\t.end code\n.end method\n";
	

	fwrite(put_char,1,strlen(put_char),output_file);
	return;
	
}




/**
 * TODO
 * @brief writes the boolean operation to the file. also stores value on the boolean
 * @param boolean the result of operation
 * @param expr_1 left hand side of expression
 * @param expr_2 right hand side of expression
 * @param rel_op the operation done. 
 * */
void rel_op(node* boolean, node* expr_1, node* expr_2, char rel_op){
	int type = expr_1->type;
	
	switch(type){
			case 1: 
			
		
			break;
		case 2 : 
		
			break;
		case 3 : 
		
		
			break;
		default:
			break;
		
		
	}
	
}


/**
 * TODO
 * @brief writes the arithmetic operation to the file. stores output value in expr
 * @param expr the result of operation
 * @param expr_1 left hand side of expression
 * @param expr_2 right hand side of expression
 * @param arit_op the operation done. 
 * */
void arithm_op(node* expr,node* expr_1, node* expr_2, int arit_op){
	//we have to put the two expression on the stack. 
	
	
	//tedious but best way to do it...
	
	
}

/**
 * TODO
 * @brief writes the logical and to the file,
 * @param expr_1 left hand side of expression
 * @param expr_2 right hand side of expresison
 * */
void logic_and(node* expr_1, node* expr_2);


/**
 * TODO
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
 * TODO
 * @brief writes if then else control to the file
 * @param boolean condition for the if
 * @param statement1 the true part
 * @param statement2 the false part
 * */
void if_then_else(node* boolean, node* statement1, node* statement2);

/**
 * TODO
 * @brief writes the for loop control flow to the file
 * @param init the initializing stateament
 * @param condition the condition to continue the loop
 * @param step the step statement
 * @param statement the statements inside the loop
 * */
void for_loop(node* init, node* condition, node* step, node* statement);
 
/**
 * TODO
 * @brief the while loop control flow to the file
 * @param boolean the condition for the loop to continue
 * @param statement the code in the loop
 * */
void while_loop(node* boolean, node* statement);

/**
 * TODO
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
void function_call(char* function_name, identifier* args,int argc){
	//we already know that the function name is correct. 
	//arguments need to be pushed on the stack BEFORE calling funciton
	char invoke[512];
	//find the return type...
	function f = find_function(function_name,args,argc);
	char args_str[512];
	
	for(int i = 0 ; i < argc; i++){
		
			identifier id = args[i];
			char* res = type_to_char(id.type);
			strcat(args_str,res);
		
	}
	char* returnT = type_to_char(f.returnType);
	sprintf(invoke,"L%d:\tinvokestatic Method %s %s (%s)%s\n",yylineno,filename, function_name,args_str,returnT);
	
	fwrite(invoke,1,strlen(invoke),output_file);
	
	return;
	
	
	
	
}
/**
 * TODO
 * @assignement writes the assignement code to the file
 * @param assigned the right hand side
 * @param assignement the left hand side
 * */
void assignement(node* assigned, node* assignement){
	//write to file the assignement in java byte code. 
	//the assigned needs to be a declared variable. 
	char* name = assigned->attribute;
	//the name is in the attribute
	
	//we need to get the type of the assigned. 
	int type = find_identifier(name);//1 = char, 2= int, 3 = float
	
	switch(type){
		case 1: 
			//char
			//we store it as an int. 
			
		
			break;
		
		
		
		
		case 2: 
		
		
		
		
			break;
		
		case 3: 
			break;
		
		default:
			break;
		
	}
	
	
	
}



/**
 * TODO
 * @brief a list of statement, takes care of the nexts etc..
 * @param concate_state the concatenated statement
 * @param stat_1 the first statement
 * @param stat_2 the second statement
 * */
void statement_list(node* concate_state,node* stat_1, node* stat_2){
	//~ stat_1.next = new_label();
	//~ stat_2.next = concate_state.next;
	
	//~ concate_state.code = concat( /* concat sentences */ stat_1.code, label(stat_1.next), stat_2.code);
	
	
}
/**
 * @brief writes the global declaration to the file
 * @param expression the declaration to be written to the file
 * */
void global_decl(node* expression){
	char* name = (char*) expression->attribute;
	char * type = type_to_char((int)expression->type);
	
	char line[512];
	
	sprintf(line,".field static %s %s\n",name,type);
	
	fwrite(line,1,strlen(line),output_file);
	return;
	
	
}


/**
 * @brief translates the type into a string that is compatible with the stack language
 * @param type the type coded in int
 * @return the string for the stack machine
 * */
char* type_to_char(int type){
	switch(type){
		case 1: return "C";
		case 2: return "I";
		case 3: return "F";
		case 4: return "[C";
		case 5: return "[I";
		case 6: return "[F";
		default: return "";
		
	}
	
	
}
