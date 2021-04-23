%{
	#include "sym_tab.c"
	#include "gpt_server.c"
	#include "check_sym_tab.c"
	#include "icg_code_gen_server.c"
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	struct ast_node
	{
		char token[20];
		char name[20];
		int dtype;
		int scope;
		int lineno;
		int valid;
		union
		{
			float f;
			int i;
			char c;
		}ast_value;
	};
	struct icg
	{
		char* tac_code;
		char* quad_code;
		char* addr;
		value v;
	};

	extern FILE* yyin;
	extern FILE* yyout;
	FILE* sym_tab_debug;
	FILE* gpt_debug;
	FILE* icg_tac;
	FILE* icg_quad;

	extern int yylex();
	extern int lineno;
	void remove_scope();
	void create_scope();

	symbol* check_sym_tab(char* name);

	void yyerror();
	int yydebug = 1;
	int scope = 0;
	int scope_1 = 0;
	int type = -1;
	int temp_no = 0;
	int label_no = 0;
	int is_first_case = -1;
	typedef struct cases
	{
		struct icg *present_case;
		char* label;
		struct cases *next;
	}cases;
	typedef struct cases_list
	{
		cases *head;
	}cases_list;
	cases_list c_list= {NULL};

	typedef struct whiles
	{
		char* top_label;
		char* bottom_label;
		struct whiles* next;
	}whiles;
	typedef struct whiles_list
	{
		whiles* head;
	}whiles_list;
	whiles_list w_list = {NULL};
%}

%union
{
	int i;
	float f;
	char c;
	char* text;
	char* label;
	struct icg* icg_t;
}

%token T_RETURN T_MAIN T_WHILE T_ENDL T_BREAK T_CONTINUE T_DEFAULT T_INT T_FLOAT T_DOUBLE T_CHAR T_VOID T_CLASS T_STRUCT T_SIZEOF T_PUBLIC T_PRIVATE T_PROTECTED T_GOTO T_UNSIGNED T_SHORT T_INCLUDE T_DEFINE T_HEADER T_STRINGLITERAL '>' '!' '+' '-' '*' '/' ':' T_OR T_AND '%' ',' '.' '[' ']' '{' '}' '(' ')' T_INCREMENT T_DECREMENT T_COUT T_CIN T_LESSTHANEQUAL T_GREATERTHANEQUAL T_EQUALTO T_NOTEQUALTO T_COUT_OP T_CIN_OP

%token <label> T_SWITCH T_CASE
%token <text> T_ID T_NUM

%type <icg_t> ASSGN EXPR T F G CASE WHILE_PARAN VAR
%type <i> BREAK POSTFIX_OP REL_OP FUNC_DECLR TYPE

%start START

%%

START
	: PROG
	;

PROG
	: T_INCLUDE '<' T_HEADER '>' PROG
	| T_DEFINE T_ID T_NUM PROG
	| T_DEFINE T_ID T_STRINGLITERAL PROG
	| T_CLASS T_ID '{' CLASS_STMT '}' PROG
	| MAIN PROG
	| FUNC_DECLR PROG
	| DECLR ';' PROG
	| ASSGN ';' PROG
	| 
	;

FUNC_DECLR
	: TYPE T_ID 
		{
			symbol* n = check_sym_tab($2);
			if(n != NULL)
			{
				char* e = (char*)malloc(sizeof(char)*(50+n->len+1));
				sprintf(e, "Function %s already defined on %d\n", $2, n->line);
				yyerror(e);
				free(e);
			}
			else
			{
				fprintf(icg_tac, "\n\nStart of Function %s\n", $2);
				fprintf(icg_quad, "\n\nStart of Function %s\n", $2);
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
				insert_symbol($2, strlen($2), type, lineno, s->top->val->scope, scope_1);
			}
		}
		'(' { create_scope(); } EMPTY_LISTVAR ')' FUNC_DECLR2
		{
			fprintf(icg_tac, "\nEnd of Function %s\n\n", $2);
			fprintf(icg_quad, "\nEnd of Function %s\n\n", $2);
		}
	;

EMPTY_LISTVAR
	: LISTVAR
	| 
	;

FUNC_DECLR2
	: '{' STMT '}' { remove_scope(); }
	| ';'
	;

MAIN
	: TYPE T_MAIN '(' 
		{
			insert_symbol(yylval.text, strlen(yylval.text), type, lineno, s->top->val->scope, scope_1);
			create_scope();
		} 
	  EMPTY_LISTVAR ')' '{' STMT '}' { remove_scope(); }
	| T_MAIN '('
		{ 
			insert_symbol(yylval.text, strlen(yylval.text), type, lineno, s->top->val->scope, scope_1);
			create_scope();
		} 
	  EMPTY_LISTVAR ')' '{' STMT '}' { remove_scope(); }
	;

CLASS_STMT
	: CLASS CLASS_STMT
	| CLASS
	;

CLASS
	: CLASS_LABEL ':'
	| DECLR2
	| FUNC_DECLR
	;

DECLR2
	: TYPE LISTVAR2
	;

LISTVAR2
	: LISTVAR2 ',' T_ID ARRAY 	{ //insert_symbol($3, strlen($3), type, lineno, s->top->val->scope, scope_1); 
								}
	| T_ID ARRAY 				{ //insert_symbol($1, strlen($1), type, lineno, s->top->val->scope, scope_1);
								}
	;

CLASS_LABEL
	: T_PUBLIC
	| T_PRIVATE
	| T_PROTECTED
	;

STMT
	: STMT_NO_BLOCK STMT
	| BLOCK STMT
	| 
	;

STMT_NO_BLOCK
	: DECLR ';'
	| ASSGN ';'
	| WHILE
	| SWITCH
	| T_COUT T_COUT_OP  COUT ';'
	| T_CIN T_CIN_OP T_ID	{
								symbol* n = check_sym_tab($3);
								if(n == NULL)
								{
									int len = strlen($3);
									char* e = (char*)malloc(sizeof(char)*(37+len+1));
									sprintf(e, "Identifier \'%s\' not defined before use\n", $3);
									yyerror(e);
									free(e);
								}
							}
	 CIN ';'
	| T_RETURN ';'
	;

BLOCK
	: '{' { create_scope(); } STMT '}' { remove_scope(); }
	;

SWITCH
	: T_SWITCH 			{
							create_scope();
						}
	'(' SWITCH2
	;

SWITCH2
	: EXPR  {
				if (c_list.head==NULL)
				{
					c_list.head = (cases*)malloc(sizeof(cases));
					c_list.head->label = new_label();
					c_list.head->present_case = $1;
					c_list.head->next = NULL;
				}
				else
				{
					cases *temp = (cases*)malloc(sizeof(cases));
					temp->present_case = $1;
					temp->label = new_label();
					temp->next = c_list.head;
					c_list.head = temp;
				}
			}
	  ')' '{' SWT_BLOCK '}'
				{
					tac_label_gen(c_list.head->label);
					quad_label_gen(c_list.head->label);
					remove_scope();
					free(c_list.head->present_case);
					cases *temp = c_list.head->next;
					free(c_list.head);
					c_list.head = temp;
				}
	| ASSGN {
				if (c_list.head==NULL)
				{
					c_list.head = (cases*)malloc(sizeof(cases));
					c_list.head->present_case = $1;
					c_list.head->label = new_label();
					c_list.head->next = NULL;
				}
				else
				{
					cases *temp = (cases*)malloc(sizeof(cases));
					temp->present_case = $1;
					temp->label = new_label();
					temp->next = c_list.head;
					c_list.head = temp;
				}
			}
	')' '{' SWT_BLOCK '}'
				{
					tac_label_gen(c_list.head->label);
					quad_label_gen(c_list.head->label);
					remove_scope();
					free(c_list.head->present_case);
					cases *temp = c_list.head->next;
					free(c_list.head);
					c_list.head = temp;
				}
	;

SWT_BLOCK
	: STMT
	| CASE SWT_BLOCK
	| T_DEFAULT ':' STMT
	;

CASE
	: T_CASE T_ID ':' 	{
							symbol* n = check_sym_tab($2);
							if(n == NULL)
							{
								int len = strlen($2);
								char* e = (char*)malloc(sizeof(char)*(37+len+1));
								sprintf(e, "Identifier \'%s\' not defined before use\n", $2);
								yyerror(e);
								free(e);
							}
							else
							{
								struct icg* temp = (struct icg*)malloc(sizeof(struct icg));
								temp->addr = new_temp();
								char* op = (char*)malloc(sizeof(char)*3);
								op[0] = op[1] = '=';
								op[2] = '\0';
								tac_code_gen(temp->addr, op, c_list.head->present_case->addr, $2, 0);
								quad_code_gen(temp->addr, op, c_list.head->present_case->addr, $2, 0);
								//char* goto_label = new_label();
								$1 = new_label();
								tac_iffalse_gen(temp->addr, $1);
								quad_iffalse_gen(temp->addr, $1);
							}
						}
	   STMT BREAK 		{
							if($6 == 1)
							{
								tac_goto_gen(c_list.head->label);
								quad_goto_gen(c_list.head->label);
							}
							tac_label_gen($1);
							quad_label_gen($1);
						}
	| T_CASE T_NUM ':'  {
							struct icg* temp = (struct icg*)malloc(sizeof(struct icg));
							temp->addr = new_temp();
							char* op = (char*)malloc(sizeof(char)*3);
							op[0] = op[1] = '=';
							op[2] = '\0';
							tac_code_gen(temp->addr, op, c_list.head->present_case->addr, $2, 0);
							quad_code_gen(temp->addr, op, c_list.head->present_case->addr, $2, 0);
							//char* goto_label = new_label();
							$1 = new_label();
							tac_iffalse_gen(temp->addr, $1);
							quad_iffalse_gen(temp->addr, $1);
						}
	   STMT BREAK 		{
							if($6 == 1)
							{
								tac_goto_gen(c_list.head->label);
								quad_goto_gen(c_list.head->label);
							}
							tac_label_gen($1);
							quad_label_gen($1);
						}
	;

BREAK
	: T_BREAK ';' { $$ = 1; }
	| { $$ = 0; }
	;

WHILE
	: T_WHILE 			{
							whiles* temp = (whiles*)malloc(sizeof(whiles));
							temp->top_label = new_label();
							temp->bottom_label = new_label();
							temp->next = w_list.head;
							w_list.head = temp;
							tac_label_gen(temp->top_label);
							quad_label_gen(temp->top_label);
							create_scope();
						}
	  '(' WHILE_PARAN 	{
	  						tac_iffalse_gen($4->addr, w_list.head->bottom_label);
	  						quad_iffalse_gen($4->addr, w_list.head->bottom_label);
	  					}
	  ')' WHILE2		{
	  						tac_goto_gen(w_list.head->top_label);
	  						quad_goto_gen(w_list.head->top_label);
							tac_label_gen(w_list.head->bottom_label);
							quad_label_gen(w_list.head->bottom_label);
							whiles* temp = w_list.head;
							w_list.head = w_list.head->next;
							free(temp);
	  					}
	;

WHILE2
	: '{' WHL_BLOCK '}' { remove_scope(); }
	| ';' { remove_scope(); }
	| STMT_NO_BLOCK { remove_scope(); }
	;

WHL_BLOCK
	: STMT
	| WHL_BLOCK BREAK 	{
							tac_goto_gen(w_list.head->bottom_label);
							quad_goto_gen(w_list.head->bottom_label);
						}
	;

WHILE_PARAN
	: EXPR				{
							$$ = $1;
						}
	| ASSGN				{
							$$ = $1;
						}
	;

COUT
	: COUT T_COUT_OP T_STRINGLITERAL
	| COUT T_COUT_OP T_ID 	{
								symbol* n = check_sym_tab($3);
								if(n == NULL)
								{
									int len = strlen($3);
									char* e = (char*)malloc(sizeof(char)*(37+len+1));
									sprintf(e, "Identifier \'%s\' not defined before use\n", $3);
									yyerror(e);
									free(e);
								}
							}
	| T_COUT_OP T_STRINGLITERAL
	| T_COUT_OP T_ID 		{
								symbol* n = check_sym_tab($2);
								if(n == NULL)
								{
									int len = strlen($2);
									char* e = (char*)malloc(sizeof(char)*(37+len+1));
									sprintf(e, "Identifier \'%s\' not defined before use\n", $2);
									yyerror(e);
									free(e);
								}
							}
	;

CIN
	: CIN T_CIN_OP T_ID 	{
								symbol* n = check_sym_tab($3);
								if(n == NULL)
								{
									int len = strlen($3);
									char* e = (char*)malloc(sizeof(char)*(37+len+1));
									sprintf(e, "Identifier \'%s\' not defined before use\n", $3);
									yyerror(e);
									free(e);
								}
							}
	| T_CIN_OP T_ID 	{	
							symbol* n = check_sym_tab($2);
							if(n == NULL)
							{
								int len = strlen($2);
								char* e = (char*)malloc(sizeof(char)*(37+len+1));
								sprintf(e, "Identifier \'%s\' not defined before use\n", $2);
								yyerror(e);
								free(e);
							}
						}
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
	: LISTVAR ',' VAR
	| VAR
	;

VAR
	: T_ID ARRAY 		{
							symbol* n = check_sym_tab($1);
							int len1 = 20;
							if(n != NULL)
							{
								int len = strlen($1);
								char* e = (char*)malloc(sizeof(char)*(40 + len + len1 + 1));
								sprintf(e, "Identifier \'%s\' already defined on line %d\n", $1, n->line);
								yyerror(e);
								free(e);
							}
							else
								insert_symbol($1, strlen($1), type, lineno, s->top->val->scope, scope_1);
						}
	| T_ID '=' EXPR 	{
							symbol* n = check_sym_tab($1);
							int len1 = 20;
							if(n != NULL)
							{
								int len = strlen($1);
								char* e = (char*)malloc(sizeof(char)*(40 + len + len1 + 1));
								sprintf(e, "Identifier \'%s\' already defined on line %d\n", $1, n->line);
								yyerror(e);
								free(e);
								$$->tac_code = NULL;
								$$->quad_code = NULL;
							}
							else
							{
								insert_symbol($1, strlen($1), type, lineno, s->top->val->scope, scope_1);
								int text_len = strlen(yylval.text) + 1;
								$$ = (struct icg*)malloc(sizeof(struct icg));
								$$->addr = (char*)malloc(sizeof(char)*text_len);
								strcpy($$->addr, $1);
								char* op = (char*)malloc(sizeof(char)*2);
								op[0] = ' ';
								op[1] = '\0';
								tac_code_gen($$->addr, op, $3->addr, op, 0);
								char* op2 = (char*)malloc(sizeof(char)*2);
								op2[0] = '=';
								op2[1] = '\0';
								quad_code_gen($$->addr, op2, $3->addr, op, 0);
								//adding this now for postfix
								$$->tac_code = NULL;
								$$->quad_code = NULL;
								if($3->tac_code != NULL)
								{
									tac_code_gen($3->tac_code, op, op, op, 1);
									quad_code_gen($3->quad_code, op, op, op, 1);
								}
							}
						}
	;

ARRAY
	: ARRAY '[' T_NUM ']'
	| '[' T_NUM ']'
	|
	;

ASSGN
	: T_ID '=' EXPR		{
							int text_len = strlen(yylval.text) + 1;
							symbol* n = check_sym_tab($1);
							$$ = (struct icg*)malloc(sizeof(struct icg));
							$$->addr = (char*)malloc(sizeof(char)*text_len);
							strcpy($$->addr, $1);
							if(n == NULL)
							{
								int len = strlen($1);
								char* e = (char*)malloc(sizeof(char)*(37+len+1));
								sprintf(e, "Identifier \'%s\' not defined before use\n", $1);
								yyerror(e);
								free(e);
								$$->tac_code = NULL;
								$$->quad_code = NULL;
							}
	 						else
	 						{
								char* op = (char*)malloc(sizeof(char)*2);
								op[0] = ' ';
								op[1] = '\0';
								tac_code_gen($$->addr, op, $3->addr, op, 0);
								char* op2 = (char*)malloc(sizeof(char)*2);
								op2[0] = '=';
								op2[1] = '\0';
								quad_code_gen($$->addr, op2, $3->addr, op, 0);
								//adding this now for postfix
								$$->tac_code = NULL;
								$$->quad_code = NULL;
								if($3->tac_code != NULL)
								{
									tac_code_gen($3->tac_code, op, op, op, 1);
									quad_code_gen($3->quad_code, op, op, op, 1);
								}
							}
						}
	;

EXPR
	: EXPR REL_OP T 	{
							$$ = (struct icg*)malloc(sizeof(struct icg));
							$$->addr = new_temp();
							char* op = (char*)malloc(sizeof(char)*3);
							op[1] = '\0';
							op[2] = '\0';
							switch($2)
							{
								case 1:
									op[0] = '<';
									op[1] = '=';
									break;
								case 2:
									op[0] = '>';
									op[1] = '=';
									break;
								case 3:
									op[0] = '<';
									break;
								case 4:
									op[0] = '>';
									break;
								case 5:
									op[0] = '=';
									op[1] = '=';
									break;
								case 6:
									op[0] = '!';
									op[1] = '=';
									break;
							}
							tac_code_gen($$->addr, op, $1->addr, $3->addr, 0);
							quad_code_gen($$->addr, op, $1->addr, $3->addr, 0);
							//adding this now for postfix
							if($3->tac_code == NULL)
							{
								if($1->tac_code == NULL)
								{
									$$->tac_code == NULL;
									$$->quad_code == NULL;
								}
								else
								{
									$$->tac_code = $1->tac_code;
									$$->quad_code = $1->quad_code;
								}
							}
							else if($3->tac_code != NULL)
							{
								if($1->tac_code == NULL)
								{
									$$->tac_code = $3->tac_code;
									$$->quad_code = $3->quad_code;
								}
								else
								{
									int tac_len1 = strlen($1->tac_code);
									int quad_len1 = strlen($1->quad_code);
									int tac_len2 = strlen($3->tac_code);
									int quad_len2 = strlen($3->quad_code);
									$$->tac_code = (char*)malloc(sizeof(char)*(tac_len1+tac_len2+1));
									$$->quad_code = (char*)malloc(sizeof(char)*(quad_len1+quad_len2+1));
									sprintf($$->tac_code,"%s%s", $1->tac_code, $3->tac_code);
									sprintf($$->quad_code,"%s%s", $1->quad_code, $3->quad_code);
								}
							}
						}
	| T 				{
							//adding this now for postfix
							$$->tac_code = $1->tac_code;
							$$->quad_code = $1->quad_code;
						}
	;

T
	: T '+' F 			{
							$$ = (struct icg*)malloc(sizeof(struct icg));
							$$->addr = new_temp();
							//$$->tac_code = (char*)malloc(sizeof(char)*300);
							char* op = (char*)malloc(sizeof(char)*2);
							op[0] = '+';
							op[1] = '\0';
							tac_code_gen($$->addr, op, $1->addr, $3->addr, 0);
							quad_code_gen($$->addr, op, $1->addr, $3->addr, 0);
							//adding this now for postfix
							if($3->tac_code == NULL)
							{
								if($1->tac_code == NULL)
								{
									$$->tac_code == NULL;
									$$->quad_code == NULL;
								}
								else
								{
									$$->tac_code = $1->tac_code;
									$$->quad_code = $1->quad_code;
								}
							}
							else if($3->tac_code != NULL)
							{
								if($1->tac_code == NULL)
								{
									$$->tac_code = $3->tac_code;
									$$->quad_code = $3->quad_code;
								}
								else
								{
									int tac_len1 = strlen($1->tac_code);
									int quad_len1 = strlen($1->quad_code);
									int tac_len2 = strlen($3->tac_code);
									int quad_len2 = strlen($3->quad_code);
									$$->tac_code = (char*)malloc(sizeof(char)*(tac_len1+tac_len2+1));
									$$->quad_code = (char*)malloc(sizeof(char)*(quad_len1+quad_len2+1));
									sprintf($$->tac_code,"%s%s", $1->tac_code, $3->tac_code);
									sprintf($$->quad_code,"%s%s", $1->quad_code, $3->quad_code);
								}
							}
						}
	| T '-' F 			{
							$$ = (struct icg*)malloc(sizeof(struct icg));
							$$->addr = new_temp();
							//$$->tac_code = (char*)malloc(sizeof(char)*300);
							char* op = (char*)malloc(sizeof(char)*2);
							op[0] = '-';
							op[1] = '\0';
							tac_code_gen($$->addr, op, $1->addr, $3->addr, 0);
							quad_code_gen($$->addr, op, $1->addr, $3->addr, 0);
							//adding this now for postfix
							if($3->tac_code == NULL)
							{
								if($1->tac_code == NULL)
								{
									$$->tac_code == NULL;
									$$->quad_code == NULL;
								}
								else
								{
									$$->tac_code = $1->tac_code;
									$$->quad_code = $1->quad_code;
								}
							}
							else if($3->tac_code != NULL)
							{
								if($1->tac_code == NULL)
								{
									$$->tac_code = $3->tac_code;
									$$->quad_code = $3->quad_code;
								}
								else
								{
									int tac_len1 = strlen($1->tac_code);
									int quad_len1 = strlen($1->quad_code);
									int tac_len2 = strlen($3->tac_code);
									int quad_len2 = strlen($3->quad_code);
									$$->tac_code = (char*)malloc(sizeof(char)*(tac_len1+tac_len2+1));
									$$->quad_code = (char*)malloc(sizeof(char)*(quad_len1+quad_len2+1));
									sprintf($$->tac_code,"%s%s", $1->tac_code, $3->tac_code);
									sprintf($$->quad_code,"%s%s", $1->quad_code, $3->quad_code);
								}
							}
						}
	| F 				{
							//adding this now for postfix
							$$->tac_code = $1->tac_code;
							$$->quad_code = $1->quad_code;
						}
	;

F
	: F '*' G 			{
							$$ = (struct icg*)malloc(sizeof(struct icg));
							$$->addr = new_temp();
							//$$->tac_code = (char*)malloc(sizeof(char)*300);
							char* op = (char*)malloc(sizeof(char)*2);
							op[0] = '*';
							op[1] = '\0';
							tac_code_gen($$->addr, op, $1->addr, $3->addr, 0);
							quad_code_gen($$->addr, op, $1->addr, $3->addr, 0);
							//adding this now for postfix
							if($3->tac_code == NULL)
							{
								if($1->tac_code == NULL)
								{
									$$->tac_code == NULL;
									$$->quad_code == NULL;
								}
								else
								{
									$$->tac_code = $1->tac_code;
									$$->quad_code = $1->quad_code;
								}
							}
							else if($3->tac_code != NULL)
							{
								if($1->tac_code == NULL)
								{
									$$->tac_code = $3->tac_code;
									$$->quad_code = $3->quad_code;
								}
								else
								{
									int tac_len1 = strlen($1->tac_code);
									int quad_len1 = strlen($1->quad_code);
									int tac_len2 = strlen($3->tac_code);
									int quad_len2 = strlen($3->quad_code);
									$$->tac_code = (char*)malloc(sizeof(char)*(tac_len1+tac_len2+1));
									$$->quad_code = (char*)malloc(sizeof(char)*(quad_len1+quad_len2+1));
									sprintf($$->tac_code,"%s%s", $1->tac_code, $3->tac_code);
									sprintf($$->quad_code,"%s%s", $1->quad_code, $3->quad_code);
								}
							}
						}
	| F '/' G 			{
							$$ = (struct icg*)malloc(sizeof(struct icg));
							$$->addr = new_temp();
							//$$->tac_code = (char*)malloc(sizeof(char)*300);
							char* op = (char*)malloc(sizeof(char)*2);
							op[0] = '/';
							op[1] = '\0';
							tac_code_gen($$->addr, op, $1->addr, $3->addr, 0);
							quad_code_gen($$->addr, op, $1->addr, $3->addr, 0);
							//adding this now for postfix
							if($3->tac_code == NULL)
							{
								if($1->tac_code == NULL)
								{
									$$->tac_code == NULL;
									$$->quad_code == NULL;
								}
								else
								{
									$$->tac_code = $1->tac_code;
									$$->quad_code = $1->quad_code;
								}
							}
							else if($3->tac_code != NULL)
							{
								if($1->tac_code == NULL)
								{
									$$->tac_code = $3->tac_code;
									$$->quad_code = $3->quad_code;
								}
								else
								{
									int tac_len1 = strlen($1->tac_code);
									int quad_len1 = strlen($1->quad_code);
									int tac_len2 = strlen($3->tac_code);
									int quad_len2 = strlen($3->quad_code);
									$$->tac_code = (char*)malloc(sizeof(char)*(tac_len1+tac_len2+1));
									$$->quad_code = (char*)malloc(sizeof(char)*(quad_len1+quad_len2+1));
									sprintf($$->tac_code,"%s%s", $1->tac_code, $3->tac_code);
									sprintf($$->quad_code,"%s%s", $1->quad_code, $3->quad_code);
								}
							}
						}
	| F '%' G 			{
							$$ = (struct icg*)malloc(sizeof(struct icg));
							$$->addr = new_temp();
							//$$->tac_code = (char*)malloc(sizeof(char)*300);
							char* op = (char*)malloc(sizeof(char)*2);
							op[0] = '%';
							op[1] = '\0';
							tac_code_gen($$->addr, op, $1->addr, $3->addr, 0);
							quad_code_gen($$->addr, op, $1->addr, $3->addr, 0);
							//adding this now for postfix
							if($3->tac_code == NULL)
							{
								if($1->tac_code == NULL)
								{
									$$->tac_code == NULL;
									$$->quad_code == NULL;
								}
								else
								{
									$$->tac_code = $1->tac_code;
									$$->quad_code = $1->quad_code;
								}
							}
							else if($3->tac_code != NULL)
							{
								if($1->tac_code == NULL)
								{
									$$->tac_code = $3->tac_code;
									$$->quad_code = $3->quad_code;
								}
								else
								{
									int tac_len1 = strlen($1->tac_code);
									int quad_len1 = strlen($1->quad_code);
									int tac_len2 = strlen($3->tac_code);
									int quad_len2 = strlen($3->quad_code);
									$$->tac_code = (char*)malloc(sizeof(char)*(tac_len1+tac_len2+1));
									$$->quad_code = (char*)malloc(sizeof(char)*(quad_len1+quad_len2+1));
									sprintf($$->tac_code,"%s%s", $1->tac_code, $3->tac_code);
									sprintf($$->quad_code,"%s%s", $1->quad_code, $3->quad_code);
								}
							}
						}
	| G 				{
							//adding this now for postfix
							$$->tac_code = $1->tac_code;
							$$->quad_code = $1->quad_code;
						}
	;

G
	: '(' EXPR ')' 		{
							$$ = $2;
						}
	| T_ID POSTFIX_OP		{
								symbol* n = check_sym_tab($1);
								$$ = (struct icg*)malloc(sizeof(struct icg));
								$$->addr = (char*)malloc(sizeof(char)*300);
								strcpy($$->addr, $1);
								if(n == NULL)
								{
									int len = strlen($1);
									char* e = (char*)malloc(sizeof(char)*(37+len+1));
									sprintf(e, "Identifier \'%s\' not defined before use\n", $1);
									yyerror(e);
									free(e);
									$$->tac_code = NULL;
									$$->quad_code = NULL;
								}
								else
								{
									if($2 == 0)
									{
										//$$->tac_code = (char*)malloc(sizeof(char)*2);
										//$$->tac_code[0] = ' ';
										//$$->tac_code[1] = '\0';
										$$->tac_code = NULL;
										$$->quad_code = NULL;
									}
									else if($2 == 1)
									{
										//char* temp = new_temp();
										$$->tac_code = (char*)malloc(sizeof(char)*300);
										$$->quad_code = (char*)malloc(sizeof(char)*300);
										sprintf($$->tac_code, "%*s = %*s +   1     \n", -20, $1, -20, $1);
										sprintf($$->quad_code, "+  , %*s, 1     , %*s\n", -20, $1, -20, $1);
									}
									else if($2 == 2)
									{
										//char* temp = new_temp();
										$$->tac_code = (char*)malloc(sizeof(char)*300);
										$$->quad_code = (char*)malloc(sizeof(char)*300);
										sprintf($$->tac_code, "%*s = %*s -   1     \n", -20, $1, -20, $1);
										sprintf($$->quad_code, "-  , %*s, 1     , %*s\n", -20, $1, -20, $1);
									}
								}
						}
	| T_NUM				{
							$$ = (struct icg*)malloc(sizeof(struct icg));
							$$->addr = (char*)malloc(sizeof(char)*300);
							strcpy($$->addr, yylval.text);
							$$->tac_code = NULL;
							$$->quad_code = NULL;
						}
	| T_INCREMENT T_ID 	{
							symbol* n = check_sym_tab($2);
							$$ = (struct icg*)malloc(sizeof(struct icg));
							$$->addr = yylval.text;
							if(n == NULL)
							{
								int len = strlen($2);
								char* e = (char*)malloc(sizeof(char)*(37+len+1));
								sprintf(e, "Identifier \'%s\' not defined before use\n", $2);
								yyerror(e);
								free(e);
							}
							else
							{
								char* temp = new_temp();
								char* op = (char*)malloc(sizeof(char)*2);
								char* op2 = (char*)malloc(sizeof(char)*2);
								op[1] = '\0';
								op2[1] = '\0';
								op[0] = '+';
								op2[0] = '1';
								tac_code_gen(temp, op, yylval.text, op2, 0);
								quad_code_gen(temp, op, yylval.text, op2, 0);
								op[0] = ' ';
								op2[0] = ' ';
								tac_code_gen(yylval.text, op, temp, op2, 0);
								quad_code_gen(yylval.text, op, temp, op2, 0);
								$$->tac_code = NULL;
								$$->quad_code = NULL;
							}
						}
	| T_DECREMENT T_ID 	{
							symbol* n = check_sym_tab($2);
							$$ = (struct icg*)malloc(sizeof(struct icg));
							$$->addr = yylval.text;
							if(n == NULL)
							{
								int len = strlen($2);
								char* e = (char*)malloc(sizeof(char)*(37+len+1));
								sprintf(e, "Identifier \'%s\' not defined before use\n", $2);
								yyerror(e);
								free(e);
							}
							else
							{
								char* temp = new_temp();
								char* op = (char*)malloc(sizeof(char)*2);
								char* op2 = (char*)malloc(sizeof(char)*2);
								op[1] = '\0';
								op2[1] = '\0';
								op[0] = '-';
								op2[0] = '1';
								tac_code_gen(temp, op, yylval.text, op2, 0);
								quad_code_gen(temp, op, yylval.text, op2, 0);
								op[0] = ' ';
								op2[0] = ' ';
								tac_code_gen(yylval.text, op, temp, op2, 0);
								quad_code_gen(temp, op, yylval.text, op2, 0);
								$$->tac_code = NULL;
								$$->quad_code = NULL;
							}
						}
	;

REL_OP
	: T_LESSTHANEQUAL { $$ = 1; }
	| T_GREATERTHANEQUAL { $$ = 2; }
	| '<' { $$ = 3; }
	| '>' { $$ = 4; }
	| T_EQUALTO { $$ = 5; }
	| T_NOTEQUALTO { $$ = 6; }
	;

POSTFIX_OP
	: T_INCREMENT	{ $$ = 1; }
	| T_DECREMENT	{ $$ = 2; }
	| { $$ = 0; }
	;

%%

void create_scope()
{
	insert_to_gpt(scope);
	fprintf(sym_tab_debug, "inserted scope: %d, scope_1: %d\n\n", scope, scope_1);
	//display_sym_tab();
	++scope;
	++scope_1;
	fprintf(gpt_debug, "displaying gpt\n");
	disp_gpt();
	fprintf(gpt_debug, "displaying stack\n");
	disp_stack();
}

void remove_scope()
{
	--scope_1;
	stack_pop();
	fprintf(gpt_debug, "displaying gpt\n");
	disp_gpt();
	fprintf(gpt_debug, "displaying stack\n");
	disp_stack();
}

int main (int argc, char *argv[])
{
	fflush(stdin);

	sym_tab_debug = fopen("sym_tab_debug.txt", "w");

	gpt_debug = fopen("gpt_debug.txt", "w");

	icg_tac = fopen("icg_tac.txt","w");

	icg_quad = fopen("icg_quad.txt","w");

	printf("sym_tab_debug %p\n", sym_tab_debug);
	printf("gpt_debug %p\n", gpt_debug);
	printf("icg_tac %p\n", icg_tac);

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
	char m[5] = "main";
	symbol* n =check_sym_tab(m);
	if(n == NULL || (n->type >=9 && n-> type <= 15))
	{
		char* e = (char*)malloc(sizeof(char)*(25));
		sprintf(e, "Function main not found\n");
		yyerror(e);
		free(e);
	}
	else
		printf("Parsing Finished\n");
	// symbol table dump
	display_sym_tab();
	fclose(sym_tab_debug);
	fclose(gpt_debug);
	fclose(icg_tac);
}