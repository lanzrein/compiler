# COM S 440 Repo for the project
## Part 0 : Introduction
### New files 
- developers.tex : Contains raw tex file for the reports

## Part 1 : Lexer 
#New files 
- lexer.l : This file is the main flex file. Contains the code for the parsing. 
- tokens.c / tokens.h : Helper file holding the tokens translation and pattern. Also a few utils method for pretty printing. 
- defines.c / defines.h : File to help handling the defines. It will help adding them in a file, removing them, checking for cycles. 
- Makefile : a Makefile. 

### Building instructions  
- make
- ./lexer <file> [debug]  

#### Notes 
- If treating files that are in different directories and have includes the includes need to have the name of the path from where the lexer is launched. 
- The building with make will produce a few warnings, for implicitly declaring and not using some variables. Disregard those warnings, as I did not need the variables. 

## Part 2 : Parser
### New files 

- lexerfiles : a folder containing the first part of the project, in case we need it at some point. 
- parser.y : This file is the file that will , with the help of bison, generate the parser code. It contains a grammar for our C language.

### Modified files 

- Makefile : has been modified to create a parser instead of a lexer 
- lexer.l : We modify it slightly so it links up with the parser.y file and gives the tokens to the parser
. 

### Building instructions  

- make 
- ./parser file [debug]

#### Notes  

- The same notes as for part 1 apply : a few warnings, and careful of the directory we use. 


## Part 3 : Type checking
### New files : 
- typecheking.h / typechecking.c : files that holds the typechecking system interface and methods
- node.c / node.h : files to represent a node. Will be used more later on to build the AST
- functions.c / functions.h : This file holds the functions and data structure to represent functions
- identifiers.h / identifiers.c : Functions and data structure to represent our identifiers. 

### Modified files : 
- parser.y : Now on most of the rules we have added a specific actions that interacts with a method of the typechecking system. 
- lexer.l : On a few inputs we prepare the terminal to make it easier for the typechecking system. 

### Building instruction
- make 
- ./compile file 

### Notes 
- The same notes as for part 1 apply : a few warnings, and careful of the directory we use. 
- For extra credit we implement : function overloading. 
- On parsing and lexer errors the compiler stops immediatly if encountering an error, on typechecking error it will continue. 



