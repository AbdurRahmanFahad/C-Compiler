%{
#include<iostream>
#include<stdlib.h>
#include<string.h>
#define YYSTYPE symbol_info*
#include "1605069_symbol_info.h"
#include "y.tab.h"
//#define YYSTYPE symbol_info*

using namespace std;

extern YYSTYPE yylval;

void yyerror(char *);

int line_count=1;
char buffer[500];
int str_cmt_start=0;
int error=0;

FILE *logout;
FILE *tokenout;

%}



digit [0-9]
letter [A-Za-z]
delim [ \t\r\f\v]
newline \n
ws [delim]+
id (_|{letter})(_|{letter}|{digit})*
integer {digit}+
number {digit}*(\.{digit}+)?(E[+-]?{digit}+)?
backslash [\\]
ADDOP [+-] 
MULOP [*/%]

%%

{delim}+	{}
{newline} {line_count++;}

"if" {return IF;}
"else" {return ELSE;}
"for" {return FOR;}
"while" {return WHILE;}
"do" {return DO;}
"int" {return INT;}
"float" {return FLOAT;}
"double" {return DOUBLE;}
"char" {return CHAR;}
"return" {return RETURN;}
"void" {return VOID;}
"break" {return BREAK;}
"switch" {return SWITCH;}
"case" {return CASE;}
"default" {return DEFAULT;}
"continue" {return CONTINUE;}
"println"	{return PRINTLN;}

{ADDOP} { 
			symbol_info *s= new  symbol_info(yytext, (char *)"ADDOP");
			yylval = (YYSTYPE)s;
			return ADDOP;
		}



{MULOP}	{
			symbol_info *s= new  symbol_info(yytext, (char *)"MULOP");
			yylval = s;
			return MULOP;
		}


"=" 	{return ASSIGNOP;}

">" |
"<" |
">=" |
"<=" |
"==" |
"!=" {
		symbol_info *s= new  symbol_info(yytext, (char *)"RELOP");
		yylval = s;
		return RELOP;
	}

"&&"	|
"||"	{
			symbol_info *s= new  symbol_info(yytext, (char *)"LOGICOP");
			yylval = s;
			return LOGICOP;
		}
"!"		{	return NOT; }


";" 	{ return SEMICOLON;}
"," 	{return COMMA;}
"(" 	{return LPAREN;}
")" 	{return RPAREN;}
"{" 	{return LCURL;}
"}" 	{return RCURL;}
"[" 	{return LTHIRD;}
"]" 	{return RTHIRD;}
"++" 	{return INCOP;}
"--" 	{return DECOP;}


{integer}	{
				symbol_info *s= new  symbol_info(yytext, (char *)"CONST_INT");
				yylval = s;
				return CONST_INT;
			}
{number} 	{	
				symbol_info *s= new  symbol_info(yytext, (char *)"CONST_FLOAT");
				yylval = s;
				return CONST_FLOAT; 
			}
{id} 		{	 
				
				symbol_info *s= new symbol_info(yytext, (char *)"ID");
				yylval = s;
				
				
				return ID;
			}

. 		{error++;
			//fprintf(logout,"\nError at line %d: Unrecognized character %s \n",yytext);
}

%%

int yywrap(void)
{
	return 1;
}





