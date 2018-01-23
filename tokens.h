/**header file for tokens. contains the definitions */

/**
 * Structure for our token translation 
 * */
#define NUM_TOKENS 44 

struct token_translate{
	const char* translation;
	const char* pattern;
};

const char * const TOKENS_MESSAGES[NUM_TOKENS];

const struct token_translate TOKENS_MAP[NUM_TOKENS];

void prettyprint(char* file,int lineno, int tokenIdx, char* text);

void processString(char* file, int lineno, char* string);

void processChar(char* file,int lineno,char* string);
