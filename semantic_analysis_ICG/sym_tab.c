#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sym_tab.h"

table* init_table()
{
	table* t = (table*)malloc(sizeof(table));
	t->head = NULL;
	return t;
}

symbol* init_symbol(char* name, int len, int type, int lineno, int scope, int scope_1)
{
	symbol* s = (symbol*)malloc(sizeof(symbol));
	s->name = (char*)malloc(sizeof(char)*(len+1));
	strcpy(s->name,name);
	s->len = len;
	s->type = type;
	s->line = lineno;
	s->scope = scope;
	s->scope_1 = scope_1;
	s->next = NULL;
	return s;
}

void insert_symbol(char* name, int len, int type, int lineno, int scope, int scope_1)
{
	symbol* s = init_symbol(name, len, type, lineno, scope, scope_1);
	if(t->head == NULL)
	{
		t->head = s;
		return;
	}
	symbol* curr = t->head;
	while(curr->next!=NULL)
		curr = curr->next;
	curr->next = s;
}

void display_sym_tab()
{
	symbol* curr = t->head;
	if(curr == NULL)
		return;
	fprintf(sym_tab_debug, "Name                \tlen  \ttype\tlineno\tscope\n");
	while(curr!=NULL)
	{
		fprintf(sym_tab_debug, "%*s\t%*d\t%*d\t%*d\t%*d\n", -20,curr->name, -5, curr->len, -4, curr->type, -6, curr->line, -5, curr->scope_1);
		curr = curr->next;
	}
}