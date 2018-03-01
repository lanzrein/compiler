#include "tokens.h"

typedef struct node{
	struct node* left;
	struct node* right;
	enum types type; //type of data if applicable
	void* attribute;
}node;

void create_node(node* n);
void set_left(node* n,node* left);
void set_right(node* n,node* right);
void set_attribute(node* n,void* data,size_t dataSize);
void delete_node(node* n);
void delete_tree(node* root);
