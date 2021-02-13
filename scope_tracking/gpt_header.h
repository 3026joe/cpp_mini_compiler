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

stack* init_stack();
s_node* init_s_node(node* val);
gpt* init_gpt();
node* init_node(int scope);