#define UNDEF 0
#define VOID 1
#define CHAR 2
#define SHORT 3
#define INT 4
#define LONG 5
#define FLOAT 6
#define DOUBLE 7
#define F_VOID 9
#define F_CHAR 10
#define F_SHORT 11
#define F_INT 12
#define F_LONG 13
#define F_FLOAT 14
#define F_DOUBLE 15

typedef union value
{
	int i;
	float f;
	double d;
	char c;
} value;

typedef struct symbol
{
	char* name;			//identifier name
	int len;			//length of identifier name
	int type;			//identifier type
	int scope;			//scope of the identifier
	int line;			//declared line number
	//int i_cal;			//????
	//value v;			//value of the variable
	struct symbol* next;
}symbol;

typedef struct table
{
	symbol* head;
}table;

static table* t;

table* init_table();
symbol* init_symbol(char* name, int len, int type, int lineno);
void insert_symbol(char* name, int len, int type, int lineno);
void display_sym_tab();