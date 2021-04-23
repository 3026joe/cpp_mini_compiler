extern int temp_no;
extern int label_no;
extern FILE* icg_tac;
extern FILE* icg_quad;

void tac_code_gen(char* a, char* op, char* b, char* c, int v);
void tac_goto_gen(char* label);
void tac_iffalse_gen(char* addr, char* label);
void tac_label_gen(char* label);
void quad_code_gen(char* a, char* op, char* b, char* c, int v);
void quad_goto_gen(char* label);
void quad_iffalse_gen(char* addr, char* label);
void quad_label_gen(char* label);
char* new_temp();
char* new_label();