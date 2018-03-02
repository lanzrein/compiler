/**
 * @file tokens.c
 * @brief header file for tokens.c
 * */
 

#define NUM_TOKENS 44 


/**
 * @struct representes a token
 * @param id the id of the TOKEN
 * @param the content of the token ( can be empty ) 
 * */
typedef struct {
	char* id;
	char* content;
}token;

//NA stands for not applicable. 
 enum types{ NA,CHAR, INT, FLOAT , CHARARR, INTARR, FLOATARR };


/**
 * @struct an array that contains the ID of all tokens. 
 * */
const char * const TOKENS_MESSAGES[NUM_TOKENS];

/**
 * @brief pretty prints a token  
 * @param file the filename
 * @param lineno current line number
 * @param tokenIdx the index of the token according to our table. (TOKENS_MESSAGES)
 * @param text the content of the token
 * */
void prettyprint(char* file,int lineno, int tokenIdx, char* text);
/**
 * @brief processes a C-string and pretty prints it. 
 * @param file the filename
 * @param lineno current line number
 * @param string the string
 * */
void processString(char* file, int lineno, char* string);
/**
 * @brief processes a char and pretty prints it. 
 * @param file the filename
 * @param lineno current line number
 * @param string a pointer to the char. 
 * */
void processChar(char* file,int lineno,char* string);

/**
 * NOT USED YET 
 * @brief this method allocates memory and creates a token
 * @param id the id
 * @param content the content of the token
 * @param tok (OUT) the token created
 * */
void createToken(char* id, char* content, token* tok);
/**
 * NOT USED YET
 * @brief frees the memory used by a token
 * @param tok the token to free
 * */
void freeToken(token* tok);
