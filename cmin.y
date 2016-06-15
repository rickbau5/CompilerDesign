%{
#include <cstdio>
#include <iostream>
#include <string>
#include <map>

using namespace std;

extern "C" int yylex();
extern "C" char* yytext;
extern "C" int yyparse();
extern "C" FILE *yyin;
 
void yyerror(const char *s);
const char* prefix();

typedef size_t yy_size_t;
extern "C" yy_size_t yyleng;
extern "C" int linenum;

int errornum = 0;

typedef struct {
    char* input;
    char* output;
    int length;
} strbox;

strbox boxStr(char*);
void buildMap();
std::map<int, char*> tokenMap;

%}

%union {
    int ival;
    float fval;
    char *sval;
    char cval;
}

%token END 
%token ENDL
%token WHITESPACE
%token INVALID

%token <sval> ID
%token <ival> NUMCONST
%token <ival> BOOLCONST
%token <sval> CHARCONST
%token <sval> STRINGCONST
%token <ival> CTOKEN
%token <sval> KEYWORD

%%
cfile:
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
    ID { cout << prefix() << "ID Value: " << $1 << endl; }
    | NUMCONST {
        cout << prefix() <<  "NUMCONST Value: " << $1 << "  Input: " << yytext << endl;
    }
    | BOOLCONST {
       cout << prefix() << "BOOLCONST Value: " << yylval.ival << "  Input: " << yytext << endl;
    }
    | CHARCONST { 
        strbox box = boxStr($1);
        if (box.length != 1) {
            string msg = "character is " + to_string(box.length) + " characters and not a single character: " + box.input;
            yyerror(msg.c_str());
        } else {
            cout << prefix() << "CHARCONST Value: \'" << box.output << "\'  Input: " << box.input << endl;
        } 
    }
    | STRINGCONST {
        strbox box = boxStr($1);
        cout << prefix() << "STRINGCONST Value of length " << box.length << ": \"" << box.output << "\"  Input: " << box.input << endl; 
    }
    | CTOKEN {
        if (yylval.ival != 0) {
            cout << prefix() << tokenMap[yylval.ival] << endl;
        } else {
            cout << prefix() << yytext << endl;
        }
    }
    | KEYWORD {
        cout << prefix() << yylval.sval << endl;
    }
    | INVALID { 
        errornum++;
        yyerrok;
        string msg = "Invalid input character: \""; 
        msg += yytext;
        msg += "\"";
        yyerror(msg.c_str());
    }
    | error {
        errornum++;
        yyerrok;
        string msg = "Invalid input: "; 
        msg += yytext;
        yyerror(msg.c_str());
    } 
    ;
WHITESPACES:
           | WHITESPACE
           | ENDL 
           ;
%%

int main(int, char**) {
    buildMap();
    /*
    FILE *myfile = fopen("a.test.file", "r");
    if (!myfile) {
        cout << "Couldn't open a.test.file!" << endl;
        return -1;
    }
    yyin = myfile;
    */
    
    do {
        yyparse();
    } while (!feof(yyin));
}

void yyerror(const char *s) {
    string base = "ERROR(" + to_string(linenum) + "): ";
    cout << base << s << endl;
}

const char* prefix() {
    string base = "Line ";
    base += to_string(linenum);
    base += " Token: "; 
    return base.c_str();
}

strbox boxStr(char* input) {
    int idx = 0;
    int cnt = 0;
    char* newStr;
    newStr = (char*)malloc(strlen(input));
    while (input[idx] != '\0') {
        if (input[idx] == '\\') {
            char next = input[idx + 1];
            switch (next) {
            case 'n':
                newStr[cnt] = '\n';
                break;
            case '0':
                newStr[cnt] = '\0';
                break;
            default:
                newStr[cnt] = next;
                break;
            }
            idx += 2;
        } else {
            newStr[cnt] = input[idx];
            idx++;
        }
        cnt++;
    }
    newStr[cnt - 1] = '\0';
    
    strbox box = { input, ++newStr, cnt - 2 };

    return box;
}

void buildMap() {
    tokenMap[1]  = strdup("ADDASS");
    tokenMap[2]  = strdup("SUBASS");
    tokenMap[3]  = strdup("MULASS");
    tokenMap[4]  = strdup("DIVASS");
    tokenMap[5]  = strdup("INC");
    tokenMap[6]  = strdup("DEC");
    tokenMap[7]  = strdup("NOTEQ");
    tokenMap[8]  = strdup("EQ");
    tokenMap[9]  = strdup("LESSEQ");
    tokenMap[10] = strdup("GRTEQ");
}
