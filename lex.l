%{
#include<stdio.h>
void yyerror(char *s);
#include "y.tab.h"
%}
digit	[0-9]
letter	[a-zA-Z]
id	{letter}({letter}|{digit})*
digits	{digit}+
opFraction	(\.{digits})?
opExponent	([Ee][+-]?{digits})?
number	{digits}{opFraction}{opExponent}
%%
int	return INT;
float	return FLOAT;
{id}	return ID;
{number}	return NUM;
[\n|\t|' ']	;
.	return *yytext;

alpha [A-Za-z_]
digit [0-9]
%%
[ \t\n]
"while" return T_WHILE;
"cout" return T_COUT;
"endl" return T_ENDL;
"break" return T_BREAK;
"continue" return T_CONTINUE;
"switch" return T_SWITCH;
"int" return T_INT;
"float" return T_FLOAT;
"double" return T_DOUBLE;
"char" return T_CHAR;
"void" return T_VOID;
"class" return T_CLASS;
"short" return T_SHORT;
"#include" return T_INCLUDE;
"main()" return T_MAIN;
{digit}+    return T_NUM;
{alpha}({alpha}|{digit})*    return T_ID;
{alpha}({alpha}|{digit})*"\.h"?   return T_HEADER;
\".*\"  return T_STRING;
"<"     return T_LESSERTHAN;
">"     return T_GREATERTHAN;
"="     return T_ASSIGNMENT;
"<="    return T_LESSTHANEQUALTO;
">="    return T_GREATERTHANEQUALTO;
"=="    return T_EQUALTO;
"!="    return T_NOTEQUALTO;
"+"     return T_PLUS;
"-"     return T_MINUS;
"*"     return T_MULTIPLY;
"/"     return T_DIVIDE;
"++"    return T_INCREMENT;
"--"    return T_DECREMENT;
"!"     return T_NOT;
"||"    return T_OR;
"&&"    return T_AND;
"%"     return T_MODULUS;   
";"     return T_SEMICOLON;
","     return T_COMMA;
"."     return T_DOT;
"["     return T_OPENSQUAREBRACKET;
"]"     return T_CLOSESQUAREBRACKET;
"[]"    return T_DIMENSIONS;
"()"    return T_PARENTHESES;
"{}"    return T_CURLYBRACES;
"{"     return T_OPENCURLYBRACES;
"}"     return T_CLOSECURLYBRACES;
"("     return T_OPENPARENTHESIS;
")"     return T_CLOSEPARENTHESIS;

.       return yytext[0];
%%
