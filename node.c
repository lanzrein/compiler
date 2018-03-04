/**
 * @file node.c 
 * @brief contains method for the handling of nodes
 * @author johan lanzrein
 * */
//node.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "node.h"

/**
 * @brief create and initialize a new node. empty
 * @param n the node 
 * */
void create_node(node* n){
	n = malloc(sizeof(node));
	if(!n){fprintf(stderr,"Error, on memory allocation\n");exit(1);}
	//TODO maybe do a few other things. 
	
}
/**
 * @brief sets the left of a node
 * @param n the node
 * @param left the left of our node 
 * */
void set_left(node* n,node* left){
	n->left = malloc(sizeof(node));
	if(!n->left){fprintf(stderr,"Error, on memory allocation\n");exit(1);}
	memcpy(n->left,left,sizeof(node));
}
/**
 * @brief sets the right of a node
 * @param n the node
 * @param right the right of our node 
 * */
void set_right(node* n,node* right){
	n->right = malloc(sizeof(node));
	if(!n->right){fprintf(stderr,"Error, on memory allocation\n");exit(1);}
	memcpy(n->right,right,sizeof(node));
}
/**
 * @brief sets the attribute of a node
 * @param n the node
 * @param data the data that will be stored in the node
 * @param dataSize the size of the data 
 * */
void set_attribute(node* n,void* data,size_t sizeData){
	n->attribute = malloc(sizeData);
	if(!n->attribute){fprintf(stderr,"Error, on memory allocation\n");exit(1);}
	memcpy(n->attribute,data,sizeData);
	return;
}
/**
 * @brief delete the node 
 * @param n the node to delete 
 * */
void delete_node(node* n){
	if(n){
		free(n->attribute);
		free(n);
	}
}
/**
 * @brief delete a whole tree from the root. 
 * @param root the root of the tree. 
 * */
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
