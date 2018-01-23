#define IF 321
#define FI 123
#define NO 234

#ifdef IF
int test(){
	printf("This part of the code should appear\n");
}


#endif

#ifdef FI
int def(){
	printf("Parsing still going on here\n");
}

#else
	printf("Those lines should be ignored ! \n");
#endif


#ifdef NOTDEF
int nonexistend = -1;
#else
int existent = 1;
#endif

#ifndef NO
printf("This is ignored\n");
#else
int defined = 321;
#endif

#ifndef TEST
int hello = 432;
#endif

#ifndef ALPHA
int dummy = 32;
#else
int cow = 42;
#endif
