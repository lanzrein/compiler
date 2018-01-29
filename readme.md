# COM S 440 Repo for the project

- developers.tex : Contains raw tex file for the reports

## Part 1 : Lexer 
- lexer.l : This file is the main flex file. Contains the code for the parsing. 
- tokens.c / tokens.h : Helper file holding the tokens translation and pattern. Also a few utils method for pretty printing. 
- defines.c / defines.h : File to help handling the defines. It will help adding them in a file, removing them, checking for cycles. 
- Makefile : a Makefile. 

### Building instructions : 
- make
- ./lexer <file> 

####Notes : 
- If treating files that are in different directories and have includes the includes need to have the name of the path from where the lexer is launched. 
- The building with make will produce a few warnings, for implicitly declaring and not using some variables. Disregard those warnings, as I did not need the variables. 