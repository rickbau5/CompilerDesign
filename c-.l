L [a-zA-Z]
D [0-9]
I [a-zA-Z0-9]
W [ \t]
N \n

%{

#include <iostream>
#include "scanType.h"

using namespace std;

#define YY_DECL extern "C" int yylex()

int linenum = 1;

%}

%x COMMENT
%x MULTICOMMENT

%%

{W}                 ;
{N}                 { ++linenum; }

{L}{I}*             { yylval.sval = strdup(yytext); return ID; }
{D}+                { cout << linenum << ": Found a NUMCONST: " << yytext << endl; }
'(\\.|[^\\'])*'     { cout << linenum << ": Found a CHARCONST: " << yytext << endl; }

"//"                BEGIN(COMMENT);
<COMMENT>[^\n]      ;
<COMMENT>{N}        { ++linenum; BEGIN(INITIAL); }

"/*"                BEGIN(MULTICOMMENT);
<MULTICOMMENT>"*/"  BEGIN(INITIAL);
<MULTICOMMENT>[^\n] ;
<MULTICOMMENT>{N}   { ++linenum; }

