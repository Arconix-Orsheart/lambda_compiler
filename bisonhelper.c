#include <stdio.h>

#include <stdlib.h>

#include <string.h>

typedef struct Comp
{
    char *name;

    char *funcs;
    int funcsLength;

    char *funcNames;
    int funcNamesLength;

    int flag;
} Comp;

typedef struct TypeNode
{
    char *type;
    struct TypeNode *next;
} TypeNode;

typedef struct TypeStack
{
    TypeNode *head;
    TypeNode *tail;
    int size;
} TypeStack;

Comp *createComp();

void setCompFlag(Comp *c, int flag);

void setCompName(Comp *c, char *name);

void addCompFunc(Comp *c, char *func, char *funcName);

void resetCompFunc(Comp *c);

char *replaceExpression(char *expr, char *search, char *replace);

TypeStack *createTypeStack();

void push(TypeStack *stack, char *type);

char *pop(TypeStack *stack);

char *peek(TypeStack *stack);

TypeStack *createTypeStack()
{
    TypeStack *stack = (TypeStack *)malloc(sizeof(TypeStack));
    stack->size = 0;
    return stack;
}

void push(TypeStack *stack, char *type)
{
    if (stack->size == 0)
    {
        stack->head = (TypeNode *)malloc(sizeof(TypeNode));
        stack->head->type = strdup(type);
        stack->tail = stack->head;
    }
    else
    {
        TypeNode *prev = (TypeNode *)malloc(sizeof(TypeNode));
        prev->type = strdup(type);
        prev->next = stack->head;
        stack->head = prev;
    }
    stack->size++;
}

char *pop(TypeStack *stack)
{
    if (stack->size == 0)
        return NULL;
    char *res = stack->head->type;
    stack->head = stack->head->next;
    stack->size--;
    return res;
}

char *peek(TypeStack *stack)
{
    return stack->head->type;
}

// Comp Helper Variables
// int main(int argc, char const *argv[])
// {
//     TypeStack *types = createTypeStack();
//     push(types, "lol");
//     push(types, "abc");
//     push(types, "gfg");
//     printf("%s", pop(types));
//     printf("%s", pop(types));
//     printf("%s", pop(types));
//     return 0;
// }

Comp *createComp()
{
    Comp *newComp = (Comp *)malloc(sizeof(Comp));

    newComp->name = "\0";
    newComp->funcs = "\0";
    newComp->funcNames = "\0";
    newComp->funcsLength = 0;
    newComp->funcNamesLength = 0;
    newComp->flag = 0;

    return newComp;
}

void setCompName(Comp *c, char *name)
{

    c->name = strdup(name);
}

void setCompFlag(Comp *c, int flag)
{
    c->flag = flag;
}

void addCompFunc(Comp *c, char *func, char *funcName)

{
    c->funcsLength += strlen(func) + 3;
    c->funcNamesLength += strlen(funcName) + 3;

    char *tempFuncs = strdup(c->funcs);
    char *tempFuncNames = strdup(c->funcNames);

    c->funcs = (char *)malloc(c->funcsLength * sizeof(char));
    c->funcNames = (char *)malloc(c->funcNamesLength * sizeof(char));

    strcat(c->funcs, tempFuncs);
    strcat(c->funcNames, tempFuncNames);

    if (tempFuncs[0] != '\0')
    {

        strcat(c->funcs, "\n\n");
        strcat(c->funcNames, ", ");
    }

    strcat(c->funcs, func);
    strcat(c->funcNames, funcName);
}

void resetCompFunc(Comp *c)
{
    c->funcs = "\0";
    c->funcNames = "\0";
}

char *replaceExpression(char *expr, char *search, char *replace)
{
    char *res;
    char *pos;

    char *temp = strdup(expr);

    int i = 0;
    while ((pos = strstr(temp, search)) != NULL)
    {
        i = pos - temp;

        res = (char *)malloc(strlen(temp) - strlen(search) + strlen(replace) + 1);
        res[0] = '\0';
        if (res == NULL)
            return NULL;

        strncpy(res, temp, i);
        res[i] = '\0';

        strcat(res, replace);

        strcat(res, temp + i + strlen(search));

        temp = strdup(res);
    }
    return res;
}
