%{
	#include <stdio.h>
	#include <string.h>
	#include "lexhelper.c"

  	#include "cgen.h"
  	#include "myanalyzer.tab.h"

  	int line_num = 1;
  	char* lineText = "\0";

	macroArray mac;
	char *tempID;
	int flag = 0;

	#define YY_USER_ACTION lineText = concatStr(lineText, yytext);
	#define YY_USER_INIT initMacros(&mac, 10);	
	
%}

DIGIT       [0-9]
INTEGER     (0|([1-9]{DIGIT}*))
DECIMAL     {INTEGER}"."{DIGIT}+
SCALAR    	{DECIMAL}([e|E][+|-]?{INTEGER})?
BOOLEAN     [True|False]

COMMON_CHAR [.|,| |a-z|A-Z|0-9]
SYMBOL_CHAR [-|+|*|/|:|_|$|%|!|#|@|&|~|^|\(|\)]
ESCAPE_CHAR (\\n|\\t|\\r|\\\\|\\\")
STRING      ({COMMON_CHAR}|{SYMBOL_CHAR}|{ESCAPE_CHAR})*

ID          [a-zA-Z][0-9a-zA-Z_]*

%x error
%x macro

%%

%{ 
  	/*Keywords*/ 
%}
integer       				{ printf("token KEYWORD_INTEGER:\t\t%s\n", yytext);	 return KW_INTEGER; }
scalar        				{ printf("token KEYWORD_SCALAR:\t\t%s\n", yytext);	 return KW_SCALAR; }
str           				{ printf("token KEYWORD_STR:\t\t%s\n", yytext); return KW_STR; }
bool          				{ printf("token KEYWORD_BOOL:\t\t%s\n", yytext); return KW_BOOL; }
True          				{ printf("token KEYWORD_TRUE:\t\t%s\n", yytext); return KW_TRUE; }
False         				{ printf("token KEYWORD_FALSE:\t\t%s\n", yytext); return KW_FALSE; }
const         				{ printf("token KEYWORD_CONST:\t\t%s\n", yytext); return KW_CONST; }
if            				{ printf("token KEYWORD_IF:\t\t%s\n", yytext); return KW_IF; }
else          				{ printf("token KEYWORD_ELSE:\t\t%s\n", yytext); return KW_ELSE; }
endif         				{ printf("token KEYWORD_ENDIF:\t\t%s\n", yytext); return KW_ENDIF; }
for           				{ printf("token KEYWORD_FOR:\t\t%s\n", yytext); return KW_FOR; }
in            				{ printf("token KEYWORD_IN:\t\t%s\n", yytext); return KW_IN; }
endfor        				{ printf("token KEYWORD_ENDFOR:\t\t%s\n", yytext); return KW_ENDFOR; }
while         				{ printf("token KEYWORD_WHILE:\t\t%s\n", yytext); return KW_WHILE; }
endwhile      				{ printf("token KEYWORD_ENDWHILE:\t\t%s\n", yytext); return KW_ENDWHILE; }
break         				{ printf("token KEYWORD_BREAK:\t\t%s\n", yytext); return KW_BREAK; }
continue      				{ printf("token KEYWORD_CONTINUE:\t\t%s\n", yytext); return KW_CONTINUE; }
not           				{ printf("token KEYWORD_NOT:\t\t%s\n", yytext); return KW_NOT; }
and           				{ printf("token KEYWORD_AND:\t\t%s\n", yytext); return KW_AND; }
or            				{ printf("token KEYWORD_OR:\t\t%s\n", yytext); return KW_OR; }
def           				{ printf("token KEYWORD_DEF:\t\t%s\n", yytext); return KW_DEF; }
enddef        				{ printf("token KEYWORD_ENDDEF:\t\t%s\n", yytext); return KW_ENDDEF; }
main          				{ printf("token KEYWORD_MAIN:\t\t%s\n", yytext); return KW_MAIN; }
return        				{ printf("token KEYWORD_RETURN:\t\t%s\n", yytext); return KW_RETURN; }
comp          				{ printf("token KEYWORD_COMP:\t\t%s\n", yytext); return KW_COMP; }
endcomp       				{ printf("token KEYWORD_ENDCOMP:\t\t%s\n", yytext); return KW_ENDCOMP; }
of            				{ printf("token KEYWORD_OF:\t\t%s\n", yytext); return KW_OF; }

%{ 
  	/*Constants*/ 
%}
{ID}	{ 
			char *value = getMacroValue(mac, yytext);
			if(value != NULL) {
				int length = strlen(value);
				for(int i = length - 1; i >= 0; i--) {
					unput(value[i]);
				}
				lineText ="\0";
			}
			else {
				printf("token IDENTIFIER:\t\t%s\n", yytext); 
				yylval.token = strdup(yytext);
				return IDENTIFIER;
			}
		}
{SCALAR}    				{ printf("token CONST_SCALAR:\t%s\n", yytext); yylval.token = strdup(yytext); return CONST_SCALAR; }
{INTEGER}     				{ printf("token CONST_INT:\t\t%s\n", yytext); yylval.token = strdup(yytext); return CONST_INT; }
{BOOLEAN}     				{ printf("token CONST_BOOL:\t\t%s\n", yytext); yylval.token = strdup(yytext); return CONST_BOOL; }
\"{STRING}\"				{ printf("token CONST_STR:\t\t%s\n", yytext); yylval.token = strdup(yytext); return CONST_STR; }

%{
	/*Macros*/
%}
^"@defmacro "/{ID}" "(\")?{STRING}(\")?\n			{ BEGIN(macro); tempID = "\0"; flag = 0;}
<macro>{ID}" "										{ if(flag == 1) {REJECT;} yytext[yyleng - 1] = '\0'; tempID = yytext; flag = 1;}
<macro>(\")?{STRING}(\")?							{ if(flag == 0) {REJECT;} addMacro(&mac, tempID, yytext); printMacros(mac); }
<macro>\n											{ BEGIN(INITIAL); lineText = "\0"; line_num++; }

%{
	/*Comment*/	
%}
"--"[^\n]*				{/*Comment: Do Nothing*/}					


%{ 
  	/*Arithmetic Operators*/ 
%}
"+"           				{ printf("token PLUS_OP:\t%s\n", yytext); return PLUS_OP; }
"-"           				{ printf("token MINUS_OP:\t%s\n", yytext); return MINUS_OP;}
"**"          				{ printf("token POW_OP:\t%s\n", yytext); return POW_OP; }
"*"           				{ printf("token MULT_OP:\t%s\n", yytext); return MULT_OP; }
"/"           				{ printf("token DIV_OP:\t%s\n", yytext); return DIV_OP; }
"%"           				{ printf("token MOD_OP:\t%s\n", yytext); return MOD_OP; }

%{ 
	/*Relational Operators*/ 
%}
"=="          				{ printf("token EQ_OP:\t%s\n", yytext); return EQ_OP; }
"!="          				{ printf("token NEQ_OP:\t%s\n", yytext); return NEQ_OP; }
"<"           				{ printf("token LT_OP:\t%s\n", yytext); return LT_OP; }
"<="          				{ printf("token LTE_OP:\t%s\n", yytext); return LTE_OP; }
">"           				{ printf("token GT_OP:\t%s\n", yytext); return GT_OP; }
">="          				{ printf("token GTE_OP:\t%s\n", yytext); return GTE_OP; }

%{
	/*Assignment Operators*/
%}
"="							{ printf("token ASSIGN_OP:\t\t%s\n", yytext); return ASSIGN_OP; }
":="						{ printf("token COLONASSIGN_OP:\t\t%s\n", yytext); return COLONASSIGN_OP; }
"+="						{ printf("token PLUSASSIGN_OP:\t\t%s\n", yytext); return PLUSASSIGN_OP; }
"-="						{ printf("token MINUSASSIGN_OP:\t\t%s\n", yytext); return MINUSASSIGN_OP; }
"*="						{ printf("token MULTASSIGN_OP:\t\t%s\n", yytext); return MULTASSIGN_OP; }
"/="						{ printf("token DIVASSIGN_OP:\t\t%s\n", yytext); return DIVASSIGN_OP; }
"%="						{ printf("token MODASSIGN_OP:\t\t%s\n", yytext); return MODASSIGN_OP; }
"->"						{ printf("token ARROW_OP:\t\t%s\n", yytext); return ARROW_OP;}
"#"							{ printf("token HASH_OP:\t\t\t%s\n", yytext); return HASH_OP; }

%{
	/*Delimiters*/
%}
";"							{ printf("token SEMICOLON:\t\t%s\n", yytext); return SEMICOLON; }
"("							{ printf("token LEFT_PARENTHESIS:\t\t%s\n", yytext); return LEFT_PARENTHESIS; }
")"							{ printf("token RIGHT_PARENTHESIS:\t%s\n", yytext); return RIGHT_PARENTHESIS; }
","							{ printf("token COMMA:\t\t\t%s\n", yytext); return COMMA; }
"["							{ printf("token LEFT_BRACKET:\t\t%s\n", yytext); return LEFT_BRACKET; }
"]"							{ printf("token RIGHT_BRACKET:\t\t%s\n", yytext); return RIGHT_BRACKET; }
":"							{ printf("token COLON:\t\t\t%s\n", yytext); return COLON; }
"."							{ printf("token PERIOD:\t\t\t%s\n", yytext); return PERIOD; }

[ \r\t]						{ /*Skip Whitespace*/ }
\n 							{ ++line_num; lineText = "\0"; }
<<EOF>> 					return EOF;

<macro,INITIAL>.			{ BEGIN(error); printf("Unrecognized token %s in line %d: %s", yytext, line_num, lineText); }
<error>[^\n]* 				{ printf("%s", yytext); }
<error>\n					{ BEGIN(INITIAL); printf("\n"); lineText = "\0"; line_num++; }



%%



/* int main() { 
	initMacros(&mac, 10);
	yylex();
} */

