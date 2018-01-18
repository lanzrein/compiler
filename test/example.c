#include "deep.c"

int file_opener(FILE* fp, char* name){
	fp = fopen(name,"r");
	if(!fp){
		return -1;
	}
	return 0;
}