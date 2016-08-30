%{

#include <iostream>

using namespace std;

extern "C" int yylex();
extern "C" int yyparse();

void yyerror(const char *s);
const char* prefix();

extern "C" FILE *yyin;

extern int linenum;

%}

%union {
    int ival;
    bool bval;
    char *sval;
    char cval;
}

%token ENDL
%token WHITESPACE

%token <sval> ID
%token <ival> NUMCONST
%token <bval> BOOLCONST
%token <sval> CHARCONST

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
     ID { printf("%s: ID Value: %s\n", prefix(), $1);  }
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
    message += " Token: ";
    return message.c_str();
}

void yyerror(const char *s) {
   printf("ERROR(%d): %s\n", linenum, s); 
}
