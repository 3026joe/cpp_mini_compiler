#!/bin/bash
yacc -d -v yacc.y
lex lex.l
gcc y.tab.c lex.yy.c -ll
./a.out test.c > output.txt