%{
	#include <unistd.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "sym_tab.h"
	#include "y.tab.h"
	void yyerror();
	int yywrap();
	char* p;
	int lineno = 1; // initialize to 1
%}

%x ML_COMMENT


digit	[0-9]
letter	[a-zA-Z]
id	{letter}({letter}|{digit})*
digits	{digit}+
opFraction	(\.{digits})?
opExponent	([Ee][+-]?{digits})?
number	{digits}{opFraction}{opExponent}

%%
\/\/.*
"/*"					{ printf("Eat up comment from line %d ", lineno); BEGIN(ML_COMMENT); }
<ML_COMMENT>"*/" 		{ printf("to line %d\n", lineno);}
<ML_COMMENT>[^*\n]+		
<ML_COMMENT>"*"			
<ML_COMMENT>"\n"		{ lineno += 1; }

"return"								return T_RETURN;
"main"									{
											p=(char*)malloc(sizeof(char)*(strlen(yytext)+1));
											strcpy(p, yytext);
											yylval.text=p;
											return T_MAIN;
										}
"while"									return T_WHILE;
"cout"									return T_COUT;
"cin"									return T_CIN;
"endl"									return T_ENDL;
"break"									return T_BREAK;
"continue"								return T_CONTINUE;
"switch"								return T_SWITCH;
"case"									return T_CASE;
"default"								return T_DEFAULT;
"int"									{ return T_INT; }
"float"									{ return T_FLOAT; }
"double"								{ return T_DOUBLE; }
"char"									{ return T_CHAR; }
"void"									{ return T_VOID; }
"class"									return T_CLASS;
"struct"								return T_STRUCT;
"sizeof"								return T_SIZEOF;
"public"								return T_PUBLIC;
"private"								return T_PRIVATE;
"protected"								return T_PROTECTED;
"goto"									return T_GOTO;
"unsigned"								return T_UNSIGNED;
"short"									{ return T_SHORT; }
"#include"								return T_INCLUDE;
"#define"								return T_DEFINE;
{number}								{
											p=(char*)malloc(sizeof(char)*(strlen(yytext)+1));
											strcpy(p, yytext);
											yylval.text=p;
											return T_NUM;
										}
{letter}({letter}|{digit})*				{
											p=(char*)malloc(sizeof(char)*(strlen(yytext)+1));
											strcpy(p, yytext);
											yylval.text=p;
											return T_ID;
										}
{letter}({letter}|{digit})*\.h			return T_HEADER;
\".*\"									return T_STRINGLITERAL;
"<<"									return T_COUT_OP;
">>"									return T_CIN_OP;
"<="									return T_LESSTHANEQUAL;
">="									return T_GREATERTHANEQUAL;
"=="									return T_EQUALTO;
"!="									return T_NOTEQUALTO;
"<"										return '<';
">"										return '>';
"="										{ return '='; }
"+"										return '+';
"-"										return '-';
"++"									return T_INCREMENT;
"--"									return T_DECREMENT;
"*"										return '*';
"/"										return '/';
"!"										return '!';
":"										return ':';
"||"									return T_OR;
"&&"									return T_AND;
"%"										return '%';
","										return ',';
"."										return '.';
"["										return '[';
"]"										return ']';
"{"										return '{';
"}"										return '}';
\(										return '(';
\)										return ')';
[\f\r\t ]
";"										return *yytext;
\n										{lineno+=1;}
.										{yyerror(NULL);}

%%
void yyerror(char* s)
{
	if(s == NULL)
		fprintf(stderr, "Unrecognized token \"%s\" on line no %d????\n", yytext, lineno);
	else
		fprintf(stderr, "On line no.: %d, %s\n", lineno, s);
}

int yywrap()
{
	return 1;
}