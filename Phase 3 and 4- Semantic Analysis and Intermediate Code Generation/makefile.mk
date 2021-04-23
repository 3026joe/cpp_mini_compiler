./a.out : y.tab.c lex.yy.c
	gcc -g y.tab.c lex.yy.c -ll -o ++g
	rm y.tab.c y.tab.h lex.yy.c
y.tab.c y.tab.h : yacc_scam_postfix.y
	yacc -d -v yacc_scam_postfix.y
lex.yy.c : lex.l sym_tab.c sym_tab.h y.tab.h
	lex lex.l