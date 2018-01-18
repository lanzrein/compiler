/**
 * @file filehandler.h
 * @brief this file contains methods and structures to help handle our different file to parse
 * */
 
 
typedef struct{
	 char* name;
	 FILE* fp;
	 int currLine;
}filehandle;


/**
 * @brief opens a new file for the parser. 
 * @param f the filehandle that will be read
 * @param name the name of the file to be opened
 * @return 0 in success < 0 in error. 
 * */
int open_newfile(filehandle* f,char* name);
/**
 * @brief close the file and free the memory
 * @param f the filehandle to close
 * @return 0 on success <0 in error 
 * */
int close_filehandle(filehandle* f);
