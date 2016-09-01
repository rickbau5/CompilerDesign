%{

#include <iostream>
#include "tokenData.h"

using namespace std;

extern "C" int yylex();
extern "C" int yyparse();

void yyerror(const char *s);
const char* prefix();

extern "C" FILE *yyin;
extern "C" char* yytext;

extern int linenum;

%}

%union {
    TokenData *tokenData;
}

%token ENDL
%token WHITESPACE

%token INVALID

%token <tokenData> ID
%token <tokenData> NUMCONST
%token <tokenData> BOOLCONST
%token <tokenData> CHARCONST

%%

file:
    lines
    ;
lines:
     lines line
     | line
     ;
line:
    TOKEN WHITESPACES
    | WHITESPACES
    ;
TOKEN:
     ID             { 
        Id* id = (Id*)$1;
        printf("%s ID Value: %s\n", prefix(), id->value); 
     }
     | NUMCONST     { 
        Num* num = (Num*)$1;
        printf("%s NUMCONST Value: %d  Input: %s\n", prefix(), num->value, num->input);
     }
     | CHARCONST    { 
        CharConst* charConst = (CharConst*)$1;
        printf("%s CHARCONST Value: '%c'  Input: %s\n", prefix(), charConst->value, charConst->input); 
     }
     | INVALID {
        yyerrok;
        string msg = "Invalid or misplaced input character: \"";
        msg += yytext;
        msg += "\"";
        yyerror(msg.c_str());
     }
     ;
WHITESPACES:
           | WHITESPACE
           | ENDL
           ;
%%

int main (int argc, char** argv) {
    printf(""); // WTF
    if (argc > 1) {
        FILE* f = fopen(argv[1], "r");
        if (!f) {
            cout << "Couldn't open the input file: " << argv[1] << endl;
            return -1;
        }
        yyin = f;
    }
    
    do {
        yyparse();
    } while (!feof(yyin));

    return 0;
}

const char* prefix() {
    string message = "Line ";
    message += to_string(linenum);
    message += " Token:";
    return message.c_str();
}

void yyerror(const char *s) {
   printf("ERROR(%d): %s\n", linenum, s); 
}

