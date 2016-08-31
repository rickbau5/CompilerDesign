%{

#include <iostream>

using namespace std;

extern "C" int yylex();
extern "C" int yyparse();

void yyerror(const char *s);
const char* prefix();

extern "C" FILE *yyin;
extern "C" char* yytext;

extern int linenum;

typedef struct {
    char* input;
    char  output;
} charbox;

charbox transChar(char*);

// Use TokenData *tokenData; below in union
%}

%union {
    int ival;
    bool bval;
    char *sval;
    char cval;
}

%token ENDL
%token WHITESPACE

%token INVALID

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
     ID             { printf("%s ID Value: %s\n", prefix(), $1);  }
     | NUMCONST     { printf("%s NUMCONST Value: %d  Input: %s\n", prefix(), $1, yytext); }
     | CHARCONST    { 
        charbox box = transChar($1);
        printf("%s CHARCONST Value: '%c'  Input: %s\n", prefix(), box.output, box.input); 
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

charbox transChar(char *charString) {
    int length = strlen(charString) - 2;
    
    char theChar;

    if (length == 1) {
        theChar = charString[1];
    } else {
        switch (charString[2]) {
        case 'n':
            theChar = '\n';
            break;
        case '0':
            theChar = '\0';
            break;
        default:
            theChar = charString[2];
            break;
        }
    }
    
    charbox box = { charString, theChar };
    return box; 
}
