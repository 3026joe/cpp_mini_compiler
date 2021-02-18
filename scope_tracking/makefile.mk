./a.out : y.tab.c lex.yy.c
	gcc y.tab.c lex.yy.c -ll
y.tab.c y.tab.h : yacc.y
	yacc -d yacc.y
lex.yy.c : lex.l sym_tab.c sym_tab.h y.tab.h
	lex lex.l