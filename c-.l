L [a-zA-Z]
D [0-9]
I [a-zA-Z0-9]
W [ \t]
N \n

C (\\.|[^\\'\n])

%{

#include <iostream>
#include "tokenData.h"
#include "scanType.h"

using namespace std;

#define YY_DECL extern "C" int yylex()

int linenum = 1;

%}

%x COMMENT
%x MULTICOMMENT

%%

"bool"              { printf("Keyword: %s\n", yytext); }
"int"               { printf("Keyword: %s\n", yytext); }
"record"            { printf("Keyword: %s\n", yytext); }

"break"             { printf("Keyword: %s\n", yytext); }
"char"              { printf("Keyword: %s\n", yytext); }
"else"              { printf("Keyword: %s\n", yytext); }
"foreach"           { printf("Keyword: %s\n", yytext); }
"if"                { printf("Keyword: %s\n", yytext); }
"in"                { printf("Keyword: %s\n", yytext); }
"return"            { printf("Keyword: %s\n", yytext); }
"static"            { printf("Keyword: %s\n", yytext); }
"while"             { printf("Keyword: %s\n", yytext); }

"true"              { printf("Keyword: %s\n", yytext); }
"false"             { printf("Keyword: %s\n", yytext); }

{W}                 ;
{N}                 { ++linenum; }

{L}{I}*             { yylval.tokenData = new Id(yytext); return ID; }
{D}+                { yylval.tokenData = new Num(yytext); return NUMCONST; }
L?'"\\"?{C}'        { yylval.tokenData = new CharConst(yytext); return CHARCONST; }

"//"                BEGIN(COMMENT);
<COMMENT>[^\n]      ;
<COMMENT>{N}        { ++linenum; BEGIN(INITIAL); }

"/*"                BEGIN(MULTICOMMENT);
<MULTICOMMENT>"*/"  BEGIN(INITIAL);
<MULTICOMMENT>[^\n] ;
<MULTICOMMENT>{N}   { ++linenum; }

.                   { return INVALID; } 
