./a.out : y.tab.c lex.yy.c
	gcc y.tab.c lex.yy.c -ll
	rm y.tab.c y.tab.h lex.yy.c
y.tab.c y.tab.h : yacc.y
	yacc -d -Wno yacc.y
lex.yy.c : lex.l sym_tab.c sym_tab.h y.tab.h
	lex lex.l