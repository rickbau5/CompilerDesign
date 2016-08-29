L [a-zA-Z]
D [0-9]
I [a-zA-Z0-9]
W [ \t]
N \n

%{
#include <iostream>
using namespace std;

#define YY_DECL extern "C" int yylex()

int linenum = 1;

%}

%x COMMENT
%x MULTICOMMENT

%%

{W}                 ;
{N}                 { ++linenum; }

{L}{I}+             { cout << linenum << ": Found an identifier: " << yytext << endl; }
{D}+                { cout << linenum << ": Found a NUMCONST: " << yytext << endl; }
'(\\.|[^\\'])*'     { cout << linenum << ": Found a CHARCONST: " << yytext << endl; }

"//"                BEGIN(COMMENT);
<COMMENT>[^\n]      ;
<COMMENT>{N}        { ++linenum; BEGIN(INITIAL); }

"/*"                BEGIN(MULTICOMMENT);
<MULTICOMMENT>"*/"  BEGIN(INITIAL);
<MULTICOMMENT>[^\n] ;
<MULTICOMMENT>{N}   { ++linenum; }

%%

int main (int argc, char** argv) {
    if (argc > 1) {
        FILE* f = fopen(argv[1], "r");
        if (!f) {
            cout << "Couldn't open the input file: " << argv[1] << endl;
            return -1;
        }
        yyin = f;
    }
    yylex();

    return 0;
}
