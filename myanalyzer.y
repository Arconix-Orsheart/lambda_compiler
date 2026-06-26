%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "cgen.h"
    #include "bisonhelper.c"
  
    extern int yylex(void);
    extern int line_num;
    
    Comp *c;

    TypeStack *types;

%}

%union
{
    char* token;
}

/* Constants */
%token <token> IDENTIFIER
%token <token> CONST_SCALAR
%token <token> CONST_INT
%token <token> CONST_BOOL
%token <token> CONST_STR

/* Keywords */
%token KW_INTEGER
%token KW_SCALAR
%token KW_STR
%token KW_BOOL
%token KW_TRUE
%token KW_FALSE
%token KW_CONST
%token KW_IF
%token KW_ELSE
%token KW_ENDIF
%token KW_FOR
%token KW_IN
%token KW_ENDFOR
%token KW_WHILE
%token KW_ENDWHILE
%token KW_BREAK
%token KW_CONTINUE
%right KW_NOT
%left KW_AND
%left KW_OR
%token KW_DEF
%token KW_ENDDEF
%token KW_MAIN
%token KW_RETURN
%token KW_COMP
%token KW_ENDCOMP
%token KW_OF

/* Arithmetic Operators */
%left PLUS_OP
%left MINUS_OP
%right POW_OP
%left MULT_OP
%left DIV_OP
%left MOD_OP

/* Relational Operators */
%left EQ_OP
%left NEQ_OP
%left LT_OP
%left LTE_OP
%left GT_OP
%left GTE_OP

/* Assignment Operators */
%right ASSIGN_OP
%right COLONASSIGN_OP
%right PLUSASSIGN_OP
%right MINUSASSIGN_OP
%right MULTASSIGN_OP
%right DIVASSIGN_OP
%right MODASSIGN_OP
%token ARROW_OP
%token HASH_OP

/* Delimiters */
%token SEMICOLON
%left LEFT_PARENTHESIS
%left RIGHT_PARENTHESIS
%token COMMA
%left LEFT_BRACKET
%left RIGHT_BRACKET
%token COLON
%left PERIOD

/* Initial Tokens */
%type <token> program
%type <token> program_body

/* Main Function */
%type <token> main

/* function_body */
%type <token> function_body
%type <token> non_empty_function_body

/* Identifiers */
%type <token> array_identifier
%type <token> pointer_identifier

/* Declarations*/
%type <token> declaration
%type <token> decl_body
%type <token> var_declaration
%type <token> const_declaration
%type <token> function_declaration
%type <token> comp_declaration

/* Comp Type */
%type <token> comp_body
%type <token> comp_var_declaration
%type <token> comp_function_declaration

/* Functions */
%type <token> param_declarations

/* Expressions */
%type <token> expression
%type <token> identifier_expr
%type <token> var_identifier_expr
%type <token> comp_identifier_expr
%type <token> period_identifier_expr
%type <token> arithmetic_expr
%type <token> relational_expr 
%type <token> logical_expr

/* Statements */
%type <token> statements
%type <token> non_empty_statements
%type <token> statement
%type <token> assign_statement
%type <token> if_statement
%type <token> for_statement
%type <token> array_statement
%type <token> while_statement
%type <token> function_statement
%type <token> return_statement
%type <token> function_args

/* types */
%type <token> type
%type <token> basic_type

%start program

%%

/* Initial Tokens */
program:
      program_body                  
      {   
       
          $$ = template("%s",$1); 
          if (yyerror_count == 0) 
          {     
                FILE *fp = fopen("bisonout.c","w");
                printf("\n\t\t\tC CODE\n");
                printf("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ \n");
                printf("\n%s\n", $1);
                printf("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ \n");
                printf("\t\t\tC CODE END\n");
                fputs("#include <stdio.h>\n",fp);
                fputs("#include <math.h>\n",fp);
                fputs(c_prologue,fp);
                fprintf(fp,"%s\n", $1);
                
                fclose(fp);               
          }
      };

program_body:
    decl_body main { $$ = template("%s\n%s\n",$1,$2); }
|   main { $$ = $1; }
;

/* Main Function */
main: 
    KW_DEF KW_MAIN LEFT_PARENTHESIS RIGHT_PARENTHESIS COLON function_body KW_ENDDEF SEMICOLON 
    {$$ = template("int main(){\n%s\n}", $6);}
;

/* Bodies */
function_body:
    %empty {$$ = "";}
|   non_empty_function_body { $$= $1; }
;

non_empty_function_body:
    var_declaration { $$ = template("%s %s", pop(types), $1); }
|   const_declaration { $$ = $1; }
|   statement { $$ = $1; }
|   statement non_empty_function_body { $$ = template("%s\n%s", $1, $2);  }
|   var_declaration non_empty_function_body { $$ = template("%s %s\n%s", pop(types), $1, $2);}
|   const_declaration non_empty_function_body { $$ = template("%s\n%s", $1, $2); }
;   


/* Identifiers */
array_identifier:
    IDENTIFIER LEFT_BRACKET expression RIGHT_BRACKET { $$ = template("%s[%s]", $1, $3); }
;

pointer_identifier:
    IDENTIFIER LEFT_BRACKET RIGHT_BRACKET { $$ = template("*%s", $1); }
;

/* Declaration Statements */
decl_body:
    decl_body declaration { $$ = template("%s\n%s", $1, $2); }
|   declaration { $$ = $1; }
;

declaration:
    var_declaration { $$ = template("%s %s", pop(types), $1); }
|   const_declaration { $$ = $1; }
|   function_declaration { $$ = $1; }
|   comp_declaration  { $$ = $1; }
;



var_declaration:
	IDENTIFIER COLON type SEMICOLON
    { 
        push(types, $3);
        if(strcmp($3, "int") && strcmp($3, "double") && strcmp($3, "char*"))
            $$ = template("%s = ctor_%s;", $1, $3); 
        else
            $$ = template("%s;", $1, $3); 
    }
|   IDENTIFIER COMMA var_declaration 
    { 
        if(strcmp(peek(types), "int") && strcmp(peek(types), "double") && strcmp(peek(types), "char*"))
            $$ = template("%s = ctor_%s, %s", $1, peek(types), $3); 
        else
            $$ = template("%s, %s", $1, $3); 
    }
|	array_identifier COLON type SEMICOLON { push(types, $3); $$ = template("%s;", $1);  }
|	array_identifier COMMA var_declaration { $$ = template("%s, %s", $1, $3);  } 
|	pointer_identifier COLON type SEMICOLON { push(types, $3); $$ = template("%s;", $1);  }
|	pointer_identifier COMMA var_declaration { $$ = template("%s, %s", $1, $3);  } 
;

const_declaration:
    KW_CONST IDENTIFIER ASSIGN_OP expression COLON basic_type SEMICOLON
    { $$ = template("const %s %s = %s;", $6, $2, $4); } 
;

function_declaration:
    KW_DEF IDENTIFIER LEFT_PARENTHESIS param_declarations RIGHT_PARENTHESIS COLON function_body KW_ENDDEF SEMICOLON
    { $$ = template("\nvoid %s(%s) {\n%s\n}", $2, $4, $7); }
|   KW_DEF IDENTIFIER LEFT_PARENTHESIS param_declarations RIGHT_PARENTHESIS ARROW_OP type COLON function_body KW_ENDDEF SEMICOLON
    { $$ = template("\n%s %s(%s) {\n%s\n}", $7, $2, $4, $9); }
;

comp_declaration:
    KW_COMP IDENTIFIER COLON comp_body KW_ENDCOMP SEMICOLON
    {
        setCompName(c, $2);
        $$ = template("\n#define SELF struct %s *self\ntypedef struct %s {\n%s\n} %s;\n\n%s\n\nconst %s ctor_%s = { %s };\n#undef SELF\n", $2, $2, $4, $2, c->funcs, $2, $2, c->funcNames);
        resetCompFunc(c);
        setCompFlag(c, 0);
    }
;

/* Comp Type */
comp_body:
    comp_var_declaration { $$ = template("%s %s", pop(types), $1); }
|   comp_function_declaration { $$ = $1; }
|   comp_var_declaration comp_body { $$ = template("%s %s\n%s", pop(types), $1, $2); }
|   comp_function_declaration comp_body { $$ = template("%s\n%s", $1, $2); }
;

comp_var_declaration:
	HASH_OP IDENTIFIER COLON type SEMICOLON { setCompFlag(c, 1); push(types, $4); $$ = template("%s;", $2);}
|   HASH_OP IDENTIFIER COMMA comp_var_declaration { $$ = template("%s, %s", $2, $4);  } 
|	HASH_OP array_identifier COLON type SEMICOLON { setCompFlag(c, 1); push(types, $4); $$ = template("%s;", $2);  }
|	HASH_OP array_identifier COMMA comp_var_declaration { $$ = template("%s, %s", $2, $4);  } 
|	HASH_OP pointer_identifier COLON type SEMICOLON { setCompFlag(c, 1); push(types, $4); $$ = template("%s;", $2);  }
|	HASH_OP pointer_identifier COMMA comp_var_declaration { $$ = template("%s, %s", $2, $4);  } 
;

comp_function_declaration:
    KW_DEF IDENTIFIER LEFT_PARENTHESIS param_declarations RIGHT_PARENTHESIS COLON function_body KW_ENDDEF SEMICOLON
    {
        addCompFunc(c, 
            template("void %s(SELF%s%s) {\n%s\n} ", $2, ($4[0] != '\0') ? ", " : "", $4 ,$7),
            template(".%s=%s", $2, $2));
        $$ = template("\nvoid (*%s)(SELF%s%s);", $2, ($4[0] != '\0') ? ", " : "", $4);
    }
|   KW_DEF IDENTIFIER LEFT_PARENTHESIS param_declarations RIGHT_PARENTHESIS ARROW_OP type COLON function_body KW_ENDDEF SEMICOLON
    {
        addCompFunc(c, 
            template("%s %s(SELF%s%s) {\n%s\n} ", $7, $2, ($4[0] != '\0') ? ", " : "", $4 ,$9),
            template(".%s=%s", $2, $2));
        $$ = template("\n%s (*%s)(SELF%s%s);", $7, $2, ($4[0] != '\0') ? ", " : "", $4);
    }
;

/* Functions */
param_declarations:
    %empty { $$ = ""; }
|   IDENTIFIER COLON type { $$ = template("%s %s", $3, $1); }
|   IDENTIFIER LEFT_BRACKET RIGHT_BRACKET COLON type { $$ = template("%s *%s", $5, $1); }
|   IDENTIFIER COLON type COMMA param_declarations { $$ = template("%s %s, %s", $3, $1, $5); }
|   IDENTIFIER LEFT_BRACKET RIGHT_BRACKET COLON type COMMA param_declarations { $$ = template("%s *%s, %s", $5, $1, $7); }
;

    
/* Expressions */
expression:
    identifier_expr { $$ = $1; }
|   arithmetic_expr { $$ = $1; }
|   relational_expr { $$ = $1; }
|   logical_expr { $$ = $1; }
|   LEFT_PARENTHESIS expression RIGHT_PARENTHESIS {$$ = template("(%s)", $2);};
|   CONST_STR { $$ = $1; }
|   KW_TRUE {$$ = template("%s", "1");}
|   KW_FALSE {$$ = template("%s", "0");} 
|   function_statement { $$ = $1; }
;

identifier_expr:
    period_identifier_expr { $$ = $1; }
|   comp_identifier_expr { $$ = $1; }
;


var_identifier_expr:
    IDENTIFIER { $$ = $1; }
|   array_identifier { $$ = $1; }
;

comp_identifier_expr:
	HASH_OP var_identifier_expr 
    { 
        if(c->flag)
            $$ = template("self->%s", $2); 
        else {
            yyerror("Outside of comp scope!");
            YYERROR;
        }
    }
|   HASH_OP var_identifier_expr PERIOD HASH_OP period_identifier_expr
    {
        if(c->flag)
            $$ = template("self->%s.%s", $2, $5); 
        else {
            yyerror("Outside of comp scope!");
            YYERROR;
        }        
    }
;

period_identifier_expr:
    var_identifier_expr { $$ = $1; }
|   var_identifier_expr PERIOD HASH_OP period_identifier_expr { $$ = template("%s.%s", $1, $4); }
;

arithmetic_expr:
    CONST_INT {$$ = $1;}
|   CONST_SCALAR {$$ = $1;}
|   expression PLUS_OP expression {$$ = template("%s + %s", $1, $3);}
|   expression MINUS_OP expression {$$ = template("%s - %s", $1, $3);}
|   expression MULT_OP expression {$$ = template("%s * %s",$1, $3);}
|   expression DIV_OP expression {$$ = template("%s / %s", $1, $3);}
|   expression MOD_OP expression {$$ = template("%s %% %s", $1, $3);}
|   expression POW_OP expression {$$ = template("pow(%s, %s)", $1, $3);}
|   PLUS_OP expression { $$ = template("+%s", $2); }
|   MINUS_OP expression { $$ = template("-%s", $2); }
;

relational_expr:
    expression LT_OP expression {$$ = template("%s < %s",$1, $3);}
|   expression LTE_OP expression {$$ = template("%s <= %s", $1, $3);}
|   expression GT_OP expression {$$ = template("%s > %s", $1, $3);}
|   expression GTE_OP expression {$$ = template("%s >= %s", $1, $3);}
|   expression EQ_OP expression {$$ = template("%s == %s", $1, $3);}
|   expression NEQ_OP expression {$$ = template("%s != %s", $1, $3);};
;

logical_expr:
    expression KW_AND expression {$$ = template("%s && %s",$1, $3);}
|   expression KW_OR expression {$$ = template("%s || %s",$1, $3);}
|   KW_NOT expression {$$ = template("!%s",$2);}
;

/* Statements */
statements:
    %empty { $$ = ""; }
|   non_empty_statements { $$ = $1; }
;

non_empty_statements:
    statement { $$ = $1; }
|   statement non_empty_statements { $$ = template("%s\n%s", $1, $2); }
;  

statement:
    SEMICOLON { $$ = template(";"); }
|   assign_statement SEMICOLON { $$ = template("%s;", $1); }
|   if_statement SEMICOLON { $$ = $1; }
|   for_statement SEMICOLON { $$ = $1; }
|   array_statement SEMICOLON { $$ = $1; }
|   while_statement SEMICOLON { $$ = $1; }
|   function_statement SEMICOLON { $$ = template("%s;", $1); } 
|   return_statement SEMICOLON { $$ = template("%s;", $1); } 
|   KW_BREAK SEMICOLON {$$ = template("break;");}
|   KW_CONTINUE SEMICOLON {$$ = template("continue;");}
;

assign_statement:
    identifier_expr ASSIGN_OP expression {$$ = template("%s = %s", $1, $3);}
|   identifier_expr PLUSASSIGN_OP expression {$$ = template("%s += %s", $1, $3);}
|   identifier_expr MINUSASSIGN_OP expression {$$ = template("%s -= %s" , $1, $3);}
|   identifier_expr MULTASSIGN_OP expression {$$ = template("%s *= %s", $1, $3);}
|   identifier_expr DIVASSIGN_OP expression {$$ = template("%s /= %s", $1, $3);}
|   identifier_expr MODASSIGN_OP expression {$$ = template("%s %%= %s", $1, $3);}; 
;

if_statement:
    KW_IF LEFT_PARENTHESIS expression RIGHT_PARENTHESIS COLON statements KW_ENDIF
    { $$ = template("\nif(%s) {\n%s\n}", $3, $6); }
|   KW_IF LEFT_PARENTHESIS expression RIGHT_PARENTHESIS COLON statements KW_ELSE COLON statements KW_ENDIF
    { $$ = template("\nif(%s) {\n%s\n} else {\n%s\n}", $3, $6, $9); }
;

for_statement:
    KW_FOR IDENTIFIER KW_IN LEFT_BRACKET expression COLON expression RIGHT_BRACKET COLON statements KW_ENDFOR
    { $$ = template("for(int %s = %s; %s < %s; %s++) {\n%s\n}", $2, $5, $2, $7, $2, $10); }
|   KW_FOR IDENTIFIER KW_IN LEFT_BRACKET expression COLON expression COLON expression RIGHT_BRACKET COLON statements KW_ENDFOR
    { $$ = template("for (int %s = %s; %s < %s; %s += %s) {\n%s\n}", $2, $5, $2, $7, $2, $9, $12); }
;

array_statement:
    IDENTIFIER COLONASSIGN_OP LEFT_BRACKET expression KW_FOR IDENTIFIER COLON expression RIGHT_BRACKET COLON type
    { $$ = template("%s *%s = (%s*)malloc(%s * sizeof(%s));\
                    \nfor(int %s = 0; %s < %s; ++%s)\
                    \n%s[%s] = %s;", $11, $1, $11, $8, $11, $6, $6, $8, $6, $1, $6, $4); }  
|	IDENTIFIER COLONASSIGN_OP LEFT_BRACKET expression KW_FOR IDENTIFIER COLON type KW_IN IDENTIFIER KW_OF expression RIGHT_BRACKET COLON type
	{ 
        char *new_expr = replaceExpression($4, $6, template("%s[%s_i]", $10, $10));
        $$ = template("%s* %s = (%s*)malloc(%s * sizeof(%s));\
					\nfor(int %s_i = 0; %s_i < %s; ++%s_i)\
					\n%s[%s_i] = %s;", $15, $1, $15, $12, $15, $10, $10, $12, $10, $1, $10, new_expr); 
    }
|	IDENTIFIER COLONASSIGN_OP LEFT_BRACKET expression KW_FOR IDENTIFIER COLON type KW_IN HASH_OP IDENTIFIER KW_OF expression RIGHT_BRACKET COLON type
	{ 
        char *new_expr = replaceExpression($4, $6, template("%s[%s_i]", $11, $11));
        $$ = template("%s* %s = (%s*)malloc(%s * sizeof(%s));\
					\nfor(int %s_i = 0; %s_i < %s; ++%s_i)\
					\n%s[%s_i] = self->%s;", $16, $1, $16, $13, $16, $11, $11, $13, $11, $1, $11, new_expr); 
    }
;

    

while_statement:
    KW_WHILE LEFT_PARENTHESIS expression RIGHT_PARENTHESIS COLON statements KW_ENDWHILE
    { $$ = template("while(%s) {\n%s\n}", $3, $6); }
;

function_args:
    expression { $$ = $1; }
|   expression COMMA function_args { $$ = template("%s, %s", $1, $3); }
;

function_statement:
    IDENTIFIER LEFT_PARENTHESIS function_args RIGHT_PARENTHESIS 
    { $$ = template("%s(%s)", $1, $3); }
|   IDENTIFIER LEFT_PARENTHESIS RIGHT_PARENTHESIS 
    { $$ = template("%s()", $1); }
|   var_identifier_expr PERIOD IDENTIFIER LEFT_PARENTHESIS function_args RIGHT_PARENTHESIS 
    { $$ = template("%s.%s(&%s, %s)", $1, $3, $1, $5); }
|   var_identifier_expr PERIOD IDENTIFIER LEFT_PARENTHESIS RIGHT_PARENTHESIS 
    { $$ = template("%s.%s(&%s)", $1, $3, $1); }
|   HASH_OP var_identifier_expr PERIOD IDENTIFIER LEFT_PARENTHESIS function_args RIGHT_PARENTHESIS 
    { $$ = template("self->%s.%s(&self->%s, %s)", $2, $4, $2, $6); }
|   HASH_OP var_identifier_expr PERIOD IDENTIFIER LEFT_PARENTHESIS RIGHT_PARENTHESIS 
    { $$ = template("self->%s.%s(&self->%s)", $2, $4, $2); }
|   HASH_OP IDENTIFIER LEFT_PARENTHESIS RIGHT_PARENTHESIS
    { $$ = template("self->%s(self)", $2); }
|   HASH_OP IDENTIFIER LEFT_PARENTHESIS function_args RIGHT_PARENTHESIS
    { $$ = template("self->%s(self, %s)", $2, $4); }
;

return_statement:
    KW_RETURN {$$ = template("return");}
|   KW_RETURN expression {$$ = template("return %s", $2);};



/* Types */
type:
    basic_type { $$ = $1; }
|   IDENTIFIER  { $$ = $1; }
;

basic_type:
    KW_INTEGER {$$ = template("%s", "int");}
|   KW_BOOL {$$ = template("%s", "int");}   // no boolean types in c and C uses ints to depict them
|   KW_SCALAR {$$ = template("%s","double");}
|   KW_STR {$$ = template("%s", "StringType");}
;


%%
int main () {
    c = createComp();
    types = createTypeStack();
    if ( yyparse() == 0 )
        printf("Accepted!\n");
    else
        printf("Rejected!\n");
}






