/**
 * @file node.h a file holding declaration of methods for the nodes
 * @author johan lanzrein
 * */

#pragma once
#include "tokens.h"
/**
 * @struct a structure representing a node of an AST
 * @param lef the left node
 * @param right the right node
 * @param type the type of the node if applicable 
 * @param sizeAttribute the size of the attribute
 * @param attribute. the attribute
 * */
typedef struct node{
	struct node* left;
	struct node* right;
	enum types type; //type of data if applicable NA is used for Operators. 
	size_t sizeAttribute;
	void* attribute;
}node;
/**
 * @brief create and initialize a new node. empty
 * @param n the node 
 * */
void create_node(node* n,enum types type);
/**
 * @brief sets the left of a node
 * @param n the node
 * @param left the left of our node 
 * */
void set_left(node* n,node* left);
/**
 * @brief sets the right of a node
 * @param n the node
 * @param right the right of our node 
 * */
void set_right(node* n,node* right);
/**
 * @brief sets the attribute of a node
 * @param n the node
 * @param data the data that will be stored in the node
 * @param dataSize the size of the data 
 * */
void set_attribute(node* n,void* data,size_t dataSize);
/**
 * @brief delete the node 
 * @param n the node to delete 
 * */
void delete_node(node* n);
/**
 * @brief delete a whole tree from the root. 
 * @param root the root of the tree. 
 * */
void delete_tree(node* root);
