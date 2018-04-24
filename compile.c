/**
 * File containing the method for generating the code. 
 * */

#include "node.h"
#include "typechecking.h"
#include "tokens.h"
#include "compile.h"

extern node* root;
extern func_list* function_list;
extern id_list* identifier_global;
extern id_list* identifier_local;

extern int yylineno;

//Setup the compiler - give the file name to open
FILE* output_file;
char filename[512];
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
//Finish up the compiler and write the file to system
void close_compiler(){
	char* end = "\n.end class\n";
	fwrite(end,1,strlen(end),output_file);

	fflush(output_file);//force to write
	fclose(output_file);
	//free what is necessary...

	return ;
	
}

//GetChar and put char 

void write_getchar(){
	//we just copy the code of a generated output..
	char* get_char = 
		".method public static putChar : (I)I \n\t.code stack 2 locals 1\n\tgetstatic Field java/lang/System out Ljava/io/PrintStream;\n\tiload_0\n\tinvokevirtual Method java/io/PrintStream print (I)V\n\tiload_0 \n\tireturn \n\n\t.end code\n.end method\n";

	fwrite(get_char,1,strlen(get_char),output_file);
	
	return;
}

void write_putchar(){
	char* put_char = 
		".method public static putChar : (I)I;\n\t.code stack 2 locals 1\n\tgetstatic Field java/lang/System out Ljava/io/PrintStream;\n\tiload_0\n\tinvokevirtual Method java/io/PrintStream print (I)V\n\tiload_0\n\tireturn\n\n\t.end code\n.end method";
	
	//idea ...
	//~ char stack[20];
	//~ sprintf(stack,"ldc \"%c\"\n",
	fwrite(put_char,1,strlen(put_char),output_file);
	return;
	
}





//For relational operations

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


//For arithmetic op

void arithm_op(node* expr,node* expr_1, node* expr_2, int arit_op){
	//we have to put the two expression on the stack. 
	
	
	//tedious but best way to do it...
	
	
}

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
//Assignements
//TODO
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



//Function definitions


//Statement list. 
void statement_list(node* concate_state,node* stat_1, node* stat_2){
	//~ stat_1.next = new_label();
	//~ stat_2.next = concate_state.next;
	
	//~ concate_state.code = concat( /* concat sentences */ stat_1.code, label(stat_1.next), stat_2.code);
	
	
}

void global_decl(node* expression){
	//name 
	char* name = (char*) expression->attribute;
	char * type = type_to_char((int)expression->type);
	
	char line[512];
	
	sprintf(line,".field static %s %s",name,type);
	
	fwrite(line,1,strlen(line),output_file);
	return;
	
	
}



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
