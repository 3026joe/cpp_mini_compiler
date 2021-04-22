symbol* check_sym_tab(char* name)
{
	//printf("NAME: %s\n",name);
	s_node* s_n = s->top;						//stack node
	while(s_n != NULL)
	{
		symbol* n = t->head;					//symbol table node
		while(n != NULL)
		{
			//printf("n->scope: %d s_n->val->scope: %d\n", n->scope, s_n->val->scope);
			if(n->scope == s_n->val->scope)
			{
				//printf("n->name: %s, name: %s\n",n->name, name);
				if(strcmp(n->name, name) == 0)
					return n;
			}
			n = n->next;
		}
		s_n = s_n->next;
	}
	return NULL;
}