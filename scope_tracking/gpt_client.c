#include <stdio.h>
#include <stdlib.h>
#include "gpt_header.h"

extern stack* s;
extern gpt* g;

int main()
{
	s = init_stack();
	g = init_gpt();
	insert_to_gpt(0);
	printf("inserted scope 0\n");
	disp_gpt();
	disp_stack();

	insert_to_gpt(1);
	printf("inserted scope 1\n");
	disp_gpt();
	disp_stack();

	insert_to_gpt(2);
	printf("inserted scope 2\n");
	disp_gpt();
	disp_stack();

	stack_pop();
	printf("popped scope 2\n");
	disp_gpt();
	disp_stack();

	insert_to_gpt(3);
	printf("inserted scope 3\n");
	disp_gpt();
	disp_stack();

	stack_pop();
	printf("popped scope 3\n");
	disp_gpt();
	disp_stack();

	insert_to_gpt(4);
	printf("inserted scope 4\n");
	disp_gpt();
	disp_stack();

	stack_pop();
	printf("popped scope 4\n");
	disp_gpt();
	disp_stack();

	stack_pop();
	printf("popped scope 1\n");
	disp_gpt();
	disp_stack();

	insert_to_gpt(5);
	printf("inserted scope 5\n");
	disp_gpt();
	disp_stack();

	stack_pop();
	printf("popped scope 5\n");
	disp_gpt();
	disp_stack();

	insert_to_gpt(6);
	printf("inserted scope 6\n");
	disp_gpt();
	disp_stack();

	stack_pop();
	printf("popped scope 6\n");
	disp_gpt();
	disp_stack();

	insert_to_gpt(7);
	printf("inserted scope 7\n");
	disp_gpt();
	disp_stack();

	stack_pop();
	printf("popped scope 7\n");
	disp_gpt();
	disp_stack();

	stack_pop();
	printf("popped scope 0\n");
	disp_gpt();
	disp_stack();
}