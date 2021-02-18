%{
	#include <unistd.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "sym_tab.h"
	#include "y.tab.h"
	void yyerror();
	int yywrap();
	int lineno = 1; // initialize to 1
	int type = -1;
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
<ML_COMMENT>"*/" 		{ printf("to line %d\n", lineno); BEGIN(INITIAL); }
<ML_COMMENT>[^*\n]+		
<ML_COMMENT>"*"			
<ML_COMMENT>"\n"		{ lineno += 1; }

"return"								return T_RETURN;
"main"									return T_MAIN;
"while"									return T_WHILE;
"cout"									return T_COUT;
"cin"									return T_CIN;
"endl"									return T_ENDL;
"break"									return T_BREAK;
"continue"								return T_CONTINUE;
"switch"								return T_SWITCH;
"case"									return T_CASE;
"default"								return T_DEFAULT;
"int"									{ type = INT; return T_INT;}
"float"									{ type = FLOAT; return T_FLOAT; }
"double"								{ type = DOUBLE; return T_DOUBLE; }
"char"									{ type = CHAR; return T_CHAR; }
"void"									{ type = VOID; return T_VOID; }
"class"									return T_CLASS;
"struct"								return T_STRUCT;
"sizeof"								return T_SIZEOF;
"public"								return T_PUBLIC;
"private"								return T_PRIVATE;
"protected"								return T_PROTECTED;
"goto"									return T_GOTO;
"unsigned"								return T_UNSIGNED;
"short"									{ type = SHORT; return T_SHORT; }
"#include"								return T_INCLUDE;
"#define"								return T_DEFINE;
{number}								return T_NUM;
{letter}({letter}|{digit})*				{ insert_symbol(yytext, strlen(yytext), type, lineno); return T_ID;}
{letter}({letter}|{digit})*\.h			return T_HEADER;
\".*\"									return T_STRINGLITERAL;
"<="									return T_LESSTHANEQUALTO;
">="									return T_GREATERTHANEQUALTO;
"=="									return T_EQUALTO;
"!="									return T_NOTEQUALTO;
"<"										return T_LESSERTHAN;
">"										return T_GREATERTHAN;
"="										{ return T_ASSIGNMENT; }
"++"									return T_INCREMENT;
"--"									return T_DECREMENT;
"+"										return T_PLUS;
"-"										return T_MINUS;
"*"										return T_MULTIPLY;
"/"										return T_DIVIDE;
"!"										return T_NOT;
"||"									return T_OR;
"&&"									return T_AND;
"%"										return T_MODULUS;
","										return T_COMMA;
"."										return T_DOT;
"[]"									return T_DIMENSIONS;
"["										return T_OPENSQUAREBRACKET;
"]"										return T_CLOSESQUAREBRACKET;
"{}"									return T_CURLYBRACES;
"{"										return T_OPENCURLYBRACES;
"}"										return T_CLOSECURLYBRACES;
\(										return T_OPENPARENTHESIS;
\)										return T_CLOSEPARENTHESIS;
[\f\r\t ]
";"										return *yytext;
\n										{lineno+=1;}
.										{yyerror();}

%%
void yyerror()
{
	fprintf(stderr, "dafuq is \"%s\" on line no %d????\n", yytext, lineno);
	exit(1);
}

int yywrap()
{
	return 1;
}