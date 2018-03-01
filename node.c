
//node.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "node.h"


void create_node(node* n){
	n = malloc(sizeof(node));
	if(!n){fprintf(stderr,"Error, on memory allocation\n");exit(1);}
	//TODO maybe do a few other things. 
	
}

void set_left(node* n,node* left){
	n->left = malloc(sizeof(node));
	if(!n->left){fprintf(stderr,"Error, on memory allocation\n");exit(1);}
	memcpy(n->left,left,sizeof(node));
}

void set_right(node* n,node* right){
	n->right = malloc(sizeof(node));
	if(!n->right){fprintf(stderr,"Error, on memory allocation\n");exit(1);}
	memcpy(n->right,right,sizeof(node));
}

void set_attribute(node* n,void* data,size_t sizeData){
	n->attribute = malloc(sizeData);
	if(!n->attribute){fprintf(stderr,"Error, on memory allocation\n");exit(1);}
	memcpy(n->attribute,data,sizeData);
	return;
}

void delete_node(node* n){
	if(n){
		free(n->attribute);
		free(n);
	}
}

void delete_tree(node* root){
	if(root->left){
		delete_tree(root->left);
	}
	if(root->right){
		delete_tree(root->right);
	}
	delete_node(root);
	
	return;
	
}
