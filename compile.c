/**
 * File containing the method for generating the code. 
 * */

#include <node.h>

//Setup the compiler - give the file name to open
FILE* output_file
int setup_compiler(char* output_name){
	//we create a file and open it. 
	char name[strlen(output_name)+2];
	strcpy(name, output_name);
	
	name[strlen(output_name)] = ".";
	name[strlen(output_name)+1] = "j";
	
	output_file = fopen(name,"w");
	if(!output_file){
		fprintf(stderr, "Error could not open file : ");
		perror(NULL);
		return -1;
	}
	
		return 0;
	
	
}
//Finish up the compiler and write the file to system
void close_compiler(){
	fflush(output_file);//force to write
	fclose(output_file);
	//free what is necessary...
	return ;
	
}

//GetChar and put char 

void write_getchar(){
	//we just copy the code of a generated output..
	char* get_char = 
		".method public static putChar : (I)I \n\t.code stack 2 locals 1\nL0:\tgetstatic Field java/lang/System out Ljava/io/PrintStream;\nL3:\tiload_0\nL4:\tinvokevirtual Method java/io/PrintStream print (I)V\nL7:\tiload_0 \nL8:\tireturn \nL9:\n\t\t.linenumbertable \n\t\t\tL0 7 \n\t\t\tL7 8 \n\t\t.end linenumbertable\n\t.end code\n.end method\n";

	fwrite(get_char,strlen(get_char),output_file);
	
	return;
}

void write_putchar();

//For relational operations

void rel_op(node* bool, node* expr_1, node* expr_2, char rel_op){
	
	
}


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

void assignement(node* assigned, node* assignement){
	//write to file the assignement in java byte code. 
	
	
	
	
}

//Function definitions


//Statement list. 
void statement_list(node* concate_state,node* stat_1, node* stat_2){
	stat_1.next = new_label();
	stat_2.next = concate_state.next;
	
	concate_state.code = concat( /* concat sentences */ stat_1.code, label(stat_1.next), stat_2.code);
	
	
}
