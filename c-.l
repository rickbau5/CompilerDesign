L [a-zA-Z]
D [0-9]
I [a-zA-Z0-9]
W [ \t]
N \n

C (\\.|[^\\'\n])

%{

#include <iostream>
#include "scanType.h"
#include "c-.tab.h"

using namespace std;

#define YY_DECL extern "C" int yylex()

int lineno = 1;

int setTokenData(int);
char formatCharConst(char*);

%}

%x COMMENT
%x MULTICOMMENT

%%

"true"|"false"      { return setTokenData(BOOLCONST); }

"<="                { return setTokenData(LESSEQ); }
"!="                { return setTokenData(NOTEQ);  }
">="                { return setTokenData(GRTEQ);  }
"=="                { return setTokenData(EQ);     }

{W}                 ;
{N}                 { ++lineno; }

{L}{I}*             { return setTokenData(ID); }
{D}+                { return setTokenData(NUMCONST); }

L?'"\\"?{C}'        { return setTokenData(CHARCONST); }

"//"                BEGIN(COMMENT);
<COMMENT>[^\n]      ;
<COMMENT>{N}        { ++lineno; BEGIN(INITIAL); }

.                   { return INVALID; } 

%%

int setTokenData(int tokenClass) {
    yylval.tokenData = new TokenData;
    yylval.tokenData->tokenClass = tokenClass;
    yylval.tokenData->lineno = lineno;
    yylval.tokenData->tokenString = strdup(yytext);

    switch (tokenClass) {
    case BOOLCONST: 
        if (strcmp("true", yytext) == 0) {
            yylval.tokenData->bval = true;
        } else {
            yylval.tokenData->bval = false;
        }
        break;
    case ID:
        break;
    case NUMCONST:
        yylval.tokenData->ival = atoi(yylval.tokenData->tokenString);
        break;
    case CHARCONST:
        yylval.tokenData->cval = formatCharConst(yylval.tokenData->tokenString);
        break;
    case LESSEQ:
        yylval.tokenData->relopval = LESSEQ;
        yylval.tokenData->tokenClass = RELOP;
        yylval.tokenData->relopString = "LESSEQ";
        break;
    case GRTEQ:
        yylval.tokenData->relopval = GRTEQ;
        yylval.tokenData->tokenClass = RELOP;
        yylval.tokenData->relopString = "GRTEQ";
        break;
    case NOTEQ:
        yylval.tokenData->relopval = NOTEQ;
        yylval.tokenData->tokenClass = RELOP;
        yylval.tokenData->relopString = "NOTEQ";
        break;
    case EQ:
        yylval.tokenData->relopval = EQ;
        yylval.tokenData->tokenClass = RELOP;
        yylval.tokenData->relopString = "EQ";
        break;
    default:
        ;
        break;
    }

    return yylval.tokenData->tokenClass;
}

char formatCharConst(char *charString) {
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
    
    return theChar; 
}
