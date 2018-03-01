//header file for functions. 

//Data structure for Functions. 

typedef struct{
	char* name;
	size_t argc;
	int lineDecl;
	types* arguments;
	types returnType;
}function;

typedef struct {
	size_t func_count;
	function* functions;
}func_list;
//TODO doc doc 

void create_function(function* f,types* args,size_t argc,char* name,int lineDecl);
void add_return_type(function* f,types returnType);
void free_function(function* f);
int functions_equals(function* f1, function* f2);
void init_list(func_list* fl);
int check_if_exists(func_list* fl,function* f);
void add_function(func_list* fl, function* f);
void copyfunc(function* copy,function* orig);
void clear_func_list(func_list* fl);
