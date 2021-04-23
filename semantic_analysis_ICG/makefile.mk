./a.out : y.tab.c lex.yy.c
	gcc -g y.tab.c lex.yy.c -ll -o ++g
	rm y.tab.c y.tab.h lex.yy.c
y.tab.c y.tab.h : yacc_final.y
	yacc -d -Wno yacc_final.y
lex.yy.c : lex.l sym_tab.c sym_tab.h y.tab.h
	lex lex.l