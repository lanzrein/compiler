/**
 * @file defines.h
 * @brief file that contains a few structures and function to help the parsing of defines
 * */
 
 #define MAX_DEFINES 1024
 #define MAX_DEFINE_LENGTH 4096
 /**
  * @struct a basic structure to hold our defines. 
  * */
 typedef struct {
	 char* identifier;
	 char* arbitraryText;
 }define;
 
 /**
  * @brief allocates memory for a define
  * @param def the define to allocate
  * @param identifier the identifier of the define
  * @param text the text of the define
  * @return 0 success < 0 on error */
 int allocDefine(define* def, char* identifier, char* text);
 
 void freeDefine(define* def);
 /**
  * @brief compares the identifier with a define. 
  * @param def1 first define
  * @param identifier 
  * @return 0 if the identifier is the same. != 0 else */
 int compareDefs(define* def1, char* identifier);
 
  
  typedef struct {
	int cursor;
	int allocatedDefs;
	define array[MAX_DEFINES];  
  }define_array;
  

 /**
  * @brief add a define to our list. 
  * @param the head 
  * @param def the define to add
  * */
 void addNode(define_array *def_arr, define* def);
 /**
  * @brief removes the define from the list. 
  * @param head pointer to the head
  * @param identifier to remove
  * */
 void removeNode(define_array *def_arr, char* identifier);
 /**
  * @brief removes all the memory allocation for the list
  * @param head the head of the list
  * */
 void freeAll(define_array *def_arr);
  
 int findIdentifier(define_array* def_arr, char* identifier);

 
 int cycleCheck(define* def1, define* def2);
 
 

 
 
 
