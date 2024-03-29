%{
	#include "sym_tab.c"
	#include "gpt_server.c"
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	extern FILE* yyin;
	extern FILE* yyout;
	FILE* sym_tab_debug;
	FILE* gpt_debug;
	extern int yylex();
	extern int lineno;
	void remove_scope();
	void create_scope();
	void yyerror();
	int scope = 0;
	int type = -1;
%}

%token T_COLON T_RETURN T_MAIN T_WHILE T_COUT T_CIN T_ENDL T_BREAK T_CONTINUE T_SWITCH T_CASE T_DEFAULT T_INT T_FLOAT T_DOUBLE T_CHAR T_VOID T_CLASS T_STRUCT T_SIZEOF T_PUBLIC T_PRIVATE T_PROTECTED T_GOTO T_UNSIGNED T_SHORT T_INCLUDE T_DEFINE T_NUM T_ID T_HEADER T_STRINGLITERAL T_LESSERTHAN T_GREATERTHAN T_ASSIGNMENT T_LESSTHANEQUALTO T_GREATERTHANEQUALTO T_EQUALTO T_NOTEQUALTO T_PLUS T_MINUS T_MULTIPLY T_DIVIDE T_INCREMENT T_DECREMENT T_NOT T_OR T_AND T_MODULUS T_COMMA T_DOT T_OPENSQUAREBRACKET T_CLOSESQUAREBRACKET T_DIMENSIONS T_CURLYBRACES T_OPENCURLYBRACES T_CLOSECURLYBRACES T_OPENPARENTHESIS T_CLOSEPARENTHESIS

%start PROG

%union
{
    int i;
    float f;
    char* text;
}

%type <i> TYPE

%%

PROG
	: T_INCLUDE INC
	| T_DEFINE T_ID DEF
	| T_CLASS T_ID '{' STMT '}'
	| MAIN PROG
	| FUNC_DECLR PROG
	| GLOBAL PROG
	| EMPTY
	;
INC
	: T_LESSERTHAN T_HEADER T_GREATERTHAN PROG
	| '"' T_HEADER '"' PROG
	;
DEF
	: T_NUM
	| T_STRINGLITERAL
	;
GLOBAL
	: DECLR ';'
	| ASSGN ';'
	;
FUNC_DECLR
	: TYPE T_ID 
		{
			if($1 == T_INT)
				type = F_INT;
			else if($1 == T_FLOAT)
				type = F_FLOAT;
			else if($1 == T_DOUBLE)
				type = F_DOUBLE;
			else if($1 == T_CHAR)
				type = F_CHAR;
			else if($1 == T_VOID)
				type = F_VOID;
			else if($1 == T_SHORT)
				type = F_SHORT;
			insert_symbol(yylval.text, strlen(yylval.text), type, lineno, scope);
		}
		T_OPENPARENTHESIS { create_scope(); } EMPTY_LISTVAR T_CLOSEPARENTHESIS FUNC_DECLR2
	;
EMPTY_LISTVAR
	: LISTVAR
	| EMPTY
	;
FUNC_DECLR2
	: T_OPENCURLYBRACES STMT T_CLOSECURLYBRACES { remove_scope(); }
	| ';'
	;
MAIN
	: TYPE T_MAIN T_OPENPARENTHESIS { create_scope(); } EMPTY_LISTVAR T_CLOSEPARENTHESIS T_OPENCURLYBRACES STMT T_CLOSECURLYBRACES { remove_scope(); }
	;
STMT
	: DECLR ';' STMT 
	| ASSGN ';' STMT
	| WHILE
	| SWITCH
	| T_COUT COUT ';' STMT
	| T_CIN CIN ';' STMT
	| T_RETURN ';' STMT
	| T_OPENCURLYBRACES { create_scope(); } STMT T_CLOSECURLYBRACES { remove_scope(); }
	| EMPTY
	;
SWITCH
	: T_SWITCH { create_scope(); } T_OPENPARENTHESIS SWITCH2
	;
SWITCH2
	: EXPR T_CLOSEPARENTHESIS T_OPENCURLYBRACES SWT_BLOCK T_CLOSECURLYBRACES
	| ASSGN T_CLOSEPARENTHESIS T_OPENCURLYBRACES SWT_BLOCK T_CLOSECURLYBRACES { remove_scope(); }
	;
SWT_BLOCK
	: STMT
	| T_CASE CASE
	| T_DEFAULT T_COLON STMT
	| EMPTY
	;
CASE
	: T_ID T_COLON STMT BREAK CASE2
	| T_NUM T_COLON STMT BREAK CASE2
	;
CASE2
	: T_CASE CASE T_COLON
	| SWT_BLOCK
	;
BREAK
	: T_BREAK ';'
	| EMPTY
	;
WHILE
	: T_WHILE { create_scope(); } T_OPENPARENTHESIS WHILE2
	;
WHILE2
	: EXPR T_CLOSEPARENTHESIS WHILE3
	| ASSGN T_CLOSEPARENTHESIS WHILE3
	| EXPR T_CLOSEPARENTHESIS ';' STMT
	| ASSGN T_CLOSEPARENTHESIS ';' STMT
	;
WHILE3
	: BLOCK { remove_scope(); } STMT
	| T_OPENCURLYBRACES STMT T_CLOSECURLYBRACES { remove_scope(); } STMT
	;
BLOCK
	: DECLR ';'
	| ASSGN ';'
	| WHILE
	| SWITCH
	| T_COUT COUT ';'
	| T_CIN CIN ';'
	| T_RETURN ';'
	;
COUT
	: T_LESSERTHAN T_LESSERTHAN COUT2
	| EMPTY
	;
COUT2
	: T_STRINGLITERAL COUT
	| T_ID COUT
	;
CIN
	: T_GREATERTHAN T_GREATERTHAN T_ID CIN
	| EMPTY
	;
DECLR
	: TYPE LISTVAR 
	;
TYPE
	: T_VOID { type = VOID; }
	| T_INT { type = INT; }
	| T_FLOAT { type = FLOAT; }
	| T_CHAR { type = CHAR; }
	| T_DOUBLE { type = DOUBLE; }
	| T_SHORT { type = SHORT; }
	;
LISTVAR
	: VAR LISTVAR2 
	;
LISTVAR2
	: ',' VAR LISTVAR2
	| EMPTY
	;
VAR
	: T_ID { insert_symbol(yylval.text, strlen(yylval.text), type, lineno, scope-1); }
	| T_ID T_ASSIGNMENT EXPR { { insert_symbol(yylval.text, strlen(yylval.text), type, lineno, scope-1); } }
	;
ASSGN
	: T_ID T_ASSIGNMENT EXPR 
	;
EXPR
	: T EXPR1 
	;
EXPR1
	: REL_OP T EXPR1
	| EMPTY
	;
T
	: F EXPR2 
	;
EXPR2
	: T_PLUS F EXPR2
	| T_MINUS F EXPR2
	| EMPTY
	;
F
	: G EXPR3	
	;
EXPR3
	: T_MULTIPLY G EXPR3
	| T_DIVIDE G EXPR3
	| T_MODULUS G EXPR3
	| EMPTY
	;
G
	: UNARY_EXPR
	| T_OPENPARENTHESIS EXPR T_CLOSEPARENTHESIS
	| T_ID
	| T_NUM 
	;
REL_OP
	: T_LESSERTHAN
	| T_GREATERTHAN
	| T_LESSTHANEQUALTO
	| T_GREATERTHANEQUALTO
	| T_EQUALTO
	| T_NOTEQUALTO
	;
UNARY_EXPR
	: T_INCREMENT T_ID
	| T_DECREMENT T_ID
	| T_ID T_INCREMENT
	| T_ID T_DECREMENT
	;
EMPTY
	:
	;

%%

void create_scope()
{
	insert_to_gpt(scope);
	fprintf(sym_tab_debug, "inserted scope %d\n\n", scope);
	++scope;
	fprintf(gpt_debug, "displaying gpt\n");
	disp_gpt();
	fprintf(gpt_debug, "displaying stack\n");
	disp_stack();
}

void remove_scope()
{
	stack_pop();
	fprintf(gpt_debug, "displaying gpt\n");
	disp_gpt();
	fprintf(gpt_debug, "displaying stack\n");
	disp_stack();
}

int main (int argc, char *argv[])
{
	sym_tab_debug = fopen("sym_tab_debug.txt", "w");

	gpt_debug = fopen("gpt_debug.txt", "w");

	printf("sym_tab_debug %p\n", sym_tab_debug);
	printf("gpt_debug %p\n", gpt_debug);

	// initialize symbol table
	t = init_table();

	// initialize stack and gpt for scope
	s = init_stack();
	g = init_gpt();

	insert_to_gpt(scope);
	++scope;

	// parsing
	yyin = fopen(argv[1], "r");
	yyparse();
	fclose(yyin);
	
	printf("Parsing finished!\n");
	
	// symbol table dump
	display_sym_tab();
}