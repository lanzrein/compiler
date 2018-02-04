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
 /**
  * @brief frees the memory of a pointer on a define
  * @param def the define to free
  * */
 void freeDefine(define* def);
 /**
  * @brief compares the identifier with a define. 
  * @param def1 first define
  * @param identifier 
  * @return 0 if the identifier is the same. != 0 else */
 int compareDefs(define* def1, char* identifier);
 
  /**
   * @brief a data structure to help simulate a list. 
   * @param size how many defines are done. 
   * @param array the actual array of defines
   * */
  typedef struct {
	int size;
	define* array;  
  }define_array;


 /**
  * @brief init initializes the def_arr. 
  * @param def_ar the array to initialize
  * */
 void initArray(define_array* def_arr);
 
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
  
  /**
   * @brief tries to match an identifier to the one we have defined. 
   * @param der_arr the define array to search from
   * @param identifier the identifier to match
   * @param the index of the identifier if there is a match ; <0 else. 
   * */
 int findIdentifier(define_array* def_arr, char* identifier);

 /**
  * @brief check for a cycle between two define !!!! ONLY BASIC CYCLES
  * @param def1 
  * @param def2 
  * @return 1 if cycle, 0 else
  * */
 int cycleCheck(define* def1, define* def2);
 
 

 
 
 
