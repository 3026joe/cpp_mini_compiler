typedef struct node
{
	struct node* sibling;
	struct node* child;
	int scope;
}node;

typedef struct gpt
{
	node* root;
}gpt;

typedef struct s_node
{
	node* val;
	struct s_node* next;
}s_node;

typedef struct stack
{
	s_node* top;
}stack;

stack* s;
gpt* g;
extern FILE* gpt_debug;

stack* init_stack();
s_node* init_s_node(node* val);
gpt* init_gpt();
node* init_node(int scope);
void stack_push(node* val);
void stack_pop();
void insert_to_gpt(int scope);
void disp_gpt();
void rec_disp_gpt(node* root);
void disp_stack();