#include <stdio.h>
#include <stdlib.h>
#include "icg_code_gen_header.h"

void tac_code_gen(char* a, char* op, char* b, char* c, int v)
{
	if(v == 0)
		fprintf(icg_tac, "%*s = %*s %*s %*s\n", -20, a, -20, b, -3, op, -20, c);
	else
		fprintf(icg_tac, "%s", a);
}

void tac_goto_gen(char* label)
{
	fprintf(icg_tac, "goto %s\n", label);
}

void tac_iffalse_gen(char* addr, char* label)
{
	fprintf(icg_tac, "iffalse %s GOTO %s\n", addr, label);
}

void tac_label_gen(char* label)
{
	fprintf(icg_tac, "%s:\n", label);
}

void quad_code_gen(char* a, char* op, char* b, char* c, int v)
{
	if(v == 0)
		fprintf(icg_quad, "%*s, %*s, %*s, %*s\n", -3, op, -20, b, -20, c, -20, a);
	else
		fprintf(icg_quad, "%s", a);
}

void quad_goto_gen(char* label)
{
	fprintf(icg_quad, "goto, , , %s\n", label);
}

void quad_iffalse_gen(char* addr, char* label)
{
	fprintf(icg_quad, "iffalse %s, , %s\n", addr, label);
}

void quad_label_gen(char* label)
{
	fprintf(icg_quad, "label, , , %s:\n", label);
}

char* new_temp()
{
	++temp_no;
	char* nt = (char*)malloc(sizeof(char)*15);
	sprintf(nt, "___t%d",temp_no);
	return nt;
}

char* new_label()
{
	++label_no;
	char* nl = (char*)malloc(sizeof(char)*15);
	sprintf(nl,"___L%d",label_no);
	return nl;
}