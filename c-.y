%{

#include <iostream>
#include <string>
#include "scanType.h"

using namespace std;

extern "C" int yylex();
extern "C" int yyparse();

void yyerror(const char *s);
const char* prefix();

extern "C" FILE *yyin;
extern "C" char* yytext;

extern int lineno;

%}

%token ENDL
%token WHITESPACE

%token INVALID

%token <tokenData> TOK

%token <tokenData> BOOLCONST
%token <tokenData> ID
%token <tokenData> CHARCONST
%token <tokenData> NUMCONST

%token <tokenData> RELOP
%token LESSEQ
%token NOTEQ
%token GRTEQ
%token EQ
%token LESS
%token GRTR

%token <tokenData> AND
%token <tokenData> NOT
%token <tokenData> OR

%token <tokenData> ASS
%token <tokenData> ADDASS
%token <tokenData> SUBASS
%token <tokenData> MULASS
%token <tokenData> DIVASS

%token <tokenData> INC
%token <tokenData> DEC
%token <tokenData> BOOL
%token <tokenData> BREAK
%token <tokenData> CHAR
%token <tokenData> ELSE
%token <tokenData> IF
%token <tokenData> IN
%token <tokenData> INT
%token <tokenData> RECORD
%token <tokenData> RETURN
%token <tokenData> STATIC
%token <tokenData> WHILE

%union {
    TokenData *tokenData;
}

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
     ID {
        printf("%s ID Value: %s\n", prefix(), $1->tokenString);
     }
     | NUMCONST {
        printf("%s NUMCONST Value: %d  Input: %s\n", prefix(), $1->ival, $1->tokenString);
     }
     | CHARCONST {
        printf("%s CHARCONST Value: '%c'  Input: %s\n", prefix(), $1->cval, $1->tokenString);
     }
     | BOOLCONST { 
        printf("%s BOOLCONST Value: %d  Input: %s\n", prefix(), $1->bval, $1->tokenString);
     }
     | RELOP {
        printf("%s %s\n", prefix(), $1->relopString); 
     }
     | AND {
        printf("%s AND\n", prefix());
     }
     | NOT {
        printf("%s NOT\n", prefix());
     }
     | OR {
        printf("%s OR\n", prefix());
     }
     | TOK {
        printf("%s %s\n", prefix(), $1->tokenStringRep);
     }
     | INVALID  {
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
    static char message[64];
    sprintf(message, "Line %d Token:", lineno);
    return message;
}

void yyerror(const char *s) {
   printf("ERROR(%d): %s\n", lineno, s); 
}

