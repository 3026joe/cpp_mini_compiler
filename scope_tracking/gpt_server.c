#include <stdio.h>
#include <stdlib.h>
#include "gpt_header.h"

//assuming global stack called s
//assuming global gpt called g

stack* init_stack()
{
	stack* s = (stack*)malloc(sizeof(stack));
	s->head = NULL;
	return s;
}

s_node* init_s_node(node* val)
{
	s_node* sn = (s_node*)malloc(sizeof(s_node));
	sn->val = val;
	sn->next = NULL;
	return sn;
}

gpt* init_gpt()
{
	gpt* g = (gpt*)malloc(sizeof(gpt));
	g->root = NULL;
	return g;
}

node* init_node(int scope)
{
	node* n = (node*)malloc(sizeof(node));
	n->sibling = NULL;
	n->child = NULL;
	n->scope = scope;
	return n;
}

void stack_push(node* val)
{
	s_node* sn = init_s_node(val);
	sn->next = s->top;
	s->top = sn;
}

void stack_pop()
{
	if(s->top == NULL)
		return;
	s_node* sn = s->top;
	s->top = s->top->next;
	free(sn);
}

void insert_to_gpt(int scope)
{
	node* n = init_node(scope);
	if(s->top != NULL)					//global scope has already been created
	{
		node* parent = s->top->val;
		n->sibling = parent->child;		//storing the parent's children as siblings to the new node 
		parent->child = n;				//updating the new node as a child to the parent
	}
	else								//creating global scope
		 gpt->root = n;
	stack_push(n);
}