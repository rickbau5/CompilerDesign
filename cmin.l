L   [a-zA-Z]
D   [0-9]
I   [a-zA-Z0-9]
W   [ \t]
N   \n
T   [!()*/+,-:;<=>?\[\]|%&{}]

%{
#include <stdio.h>
#include <cstdio>
#include <iostream>
using namespace std;
#define YY_DECL extern "C" int yylex()

#include "cmin.tab.h"  // to get the token types that we return
int linenum = 1;

// Constants
char* FOREACH = strdup("FOREACH");
char* RETURN  = strdup("RETURN");
char* STATIC  = strdup("STATIC");
char* WHILE   = strdup("WHILE");
char* BREAK   = strdup("BREAK");
char* BOOL    = strdup("BOOL");
char* CHAR    = strdup("CHAR");
char* ELSE    = strdup("ELSE");
char* INT     = strdup("INT");
char* IF      = strdup("IF");
char* IN      = strdup("IN");

%}

%x comment

%%

"bool"              { yylval.sval = BOOL; return KEYWORD; }
"break"             { yylval.sval = BREAK; return KEYWORD; }
"char"              { yylval.sval = CHAR; return KEYWORD; }
"else"              { yylval.sval = ELSE; return KEYWORD; }
"foreach"           { yylval.sval = FOREACH; return KEYWORD; }
"if"                { yylval.sval = IF; return KEYWORD; }
"in"                { yylval.sval = IN; return KEYWORD; }
"int"               { yylval.sval = INT; return KEYWORD; }
"return"            { yylval.sval = RETURN; return KEYWORD; }
"static"            { yylval.sval = STATIC; return KEYWORD; }
"while"             { yylval.sval = WHILE; return KEYWORD; }

"true"              { yylval.ival = 1; return BOOLCONST; }
"false"             { yylval.ival = 0; return BOOLCONST; }

{W}                 { return WHITESPACE; }

{L}{I}*             { yylval.sval = strdup(yytext); return ID; }
{D}+                { yylval.ival = atoi(yytext); return NUMCONST; }
L?\"(\\.|[^\\"\n])*\" { yylval.sval = strdup(yytext); return STRINGCONST; }
L?'(\\.|[^\\'])*'   { yylval.sval = strdup(yytext); return CHARCONST; }

"."                 { return INVALID; }

"+="                { yylval.ival = 1;  return CTOKEN; }
"-="                { yylval.ival = 2;  return CTOKEN; }
"*="                { yylval.ival = 3;  return CTOKEN; }
"/="                { yylval.ival = 4;  return CTOKEN; }
"++"                { yylval.ival = 5;  return CTOKEN; }
"--"                { yylval.ival = 6;  return CTOKEN; }
"!="                { yylval.ival = 7;  return CTOKEN; }
"=="                { yylval.ival = 8;  return CTOKEN; }
"<="                { yylval.ival = 9;  return CTOKEN; }
">="                { yylval.ival = 10; return CTOKEN; }

{T}                 { yylval.ival = 0;  return CTOKEN; }

{N}                 { ++linenum; return ENDL; }

"//"                BEGIN(comment);

<comment>[^\n]      ;
<comment>{N}        { ++linenum; BEGIN(INITIAL); }

.                   { return INVALID; }

%%
