#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct
{
    char *id;
    char *value;
} macro;

typedef struct
{
    macro *macros;
    int used;
    int size;
} macroArray;

char *concatStr(char *res, char *input);

void initMacros(macroArray *arr, int initialSize);

void addMacro(macroArray *arr, char *id, char *value);

macro *createMacro(char *id, char *value);

char *getMacroValue(macroArray arr, char *id);

void printMacros(macroArray arr);

char **getIdValue(char *text);

// int main(int argc, char const *argv[])
// {
//     macroArray arr;
//     initMacros(&arr, 10);
//     addMacro(&arr, "a", "ded");
//     addMacro(&arr, "b", "lel");
//     printf("ArrLength: %d\n", arr.used);
//     for (int i = 0; i < arr.used; i++)
//     {
//         printf("arr[%d] = Macro(%s, %s)\n", i, arr.macros[i].id, arr.macros[i].value);
//     }
//     char *value = getMacroValue(arr, "c");
//     if(value != NULL) {
//         printf("%s", value);
//     } else {
//         printf("lol");
//     }
//     return 0;
// }


char *concatStr(char *res, char *str)
{
    char *temp = (char *)malloc((strlen(res) + strlen(str) + 1) * sizeof(char));
    strcpy(temp, res);
    strcat(temp, str);
    return temp;
}

void initMacros(macroArray *arr, int initialSize)
{
    arr->macros = malloc(initialSize * sizeof(macro));
    arr->used = 0;
    arr->size = initialSize;
}

char *getMacroValue(macroArray arr, char *id)
{
    for (int i = 0; i < arr.used; i++)
    {
        if (strcmp(arr.macros[i].id, id) == 0)
            return arr.macros[i].value;
    }
    return NULL;
}

macro *createMacro(char *id, char *value)
{
    macro *newMacro = (macro *)malloc(sizeof(macro));
    if (newMacro != NULL)
    {
        newMacro->id = strdup(id);
        newMacro->value = strdup(value);
    }
    return newMacro;
}

void addMacro(macroArray *arr, char *id, char *value)
{
    if (arr->used == arr->size)
    {
        arr->size *= 2;
        arr->macros = realloc(arr->macros, (arr->size) * sizeof(macro));
    }
    (arr->macros)[arr->used] = *createMacro(id, value);
    arr->used++;
}

void printMacros(macroArray arr)
{
    for (int i = 0; i < arr.used; i++)
    {
        printf("arr[%d] = Macro(%s, %s)\n", i, arr.macros[i].id, arr.macros[i].value);
    }
}

