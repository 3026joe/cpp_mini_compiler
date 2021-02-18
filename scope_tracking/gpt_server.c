#include <stdio.h>
#include <stdlib.h>
#include "gpt_header.h"

//assuming global stack called s
//assuming global gpt called g

stack* init_stack()
{
	stack* s_new = (stack*)malloc(sizeof(stack));
	s_new->top = NULL;
	return s_new;
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
	gpt* g_new = (gpt*)malloc(sizeof(gpt));
	g_new->root = NULL;
	return g_new;
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
		 g->root = n;
	stack_push(n);
}

void disp_gpt()
{
	if(g->root == NULL)
		fprintf(gpt_debug, "GPT Empty\n");
	else
		rec_disp_gpt(g->root);
	fprintf(gpt_debug, "\n\n");
}

void rec_disp_gpt(node* root)
{
	if(root == NULL)
		return;
	fprintf(gpt_debug, "%d has children: ",root->scope);
	node* c = root->child;
	while(c != NULL)
	{
		fprintf(gpt_debug, "%d\t", c->scope);
		c = c->sibling;
	}
	fprintf(gpt_debug, "\n");
	rec_disp_gpt(root->sibling);
	rec_disp_gpt(root->child);
}

void disp_stack()
{
	s_node* sn = s->top;
	while(sn != NULL)
	{
		fprintf(gpt_debug, "%d\n",sn->val->scope);
		sn = sn->next;
	}
}