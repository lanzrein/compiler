#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "filehandler.h"

int open_newfile(filehandle* f,char* name){
	if(NULL==f){
		return -1;
	}
	
	f->fp = fopen(name,"r");
	if(NULL == f->fp){
		return -1;
	}
	f->name = malloc(strlen(name));
	memcpy(f->name,name,strlen(name));
	f->currLine = 1;
	
	return 0;
}

int close_filehandle(filehandle* f){
	if(NULL==f){
		return -1;
	}
	//close the file
	fclose(f->fp);
	free(f->name);
	free(f);
	return 0;
}
