#!/bin/bash
yacc -d -Wno yacc_copy_1.y
lex lex_1.l
gcc y.tab.c lex.yy.c -ll
./a.out test.c > output.txt