L [a-zA-Z]
D [0-9]
I [a-zA-Z0-9]
W [ \t]
N \n

C (\\.|[^\\'\n])

%{

#include <iostream>
#include <string>
#include <map>
#include "symbolTable.h"
#include "scanType.h"
#include "c-.tab.h"
#include "c-.h"

using namespace std;

#define YY_DECL extern "C" int yylex()

int lineno = 1;

int setTokenData(int);
char formatCharConst(char*);

extern SymbolTable symbolTable;

%}

%option noyywrap

%x COMMENT
%x MULTICOMMENT

%%

"true"|"false"      { return setTokenData(BOOLCONST); }

"<="                { return setTokenData(LESSEQ); }
"!="                { return setTokenData(NOTEQ);  }
">="                { return setTokenData(GRTEQ);  }
"=="                { return setTokenData(EQ);     }

">"                 { return setTokenData(GRTR); }
"<"                 { return setTokenData(LESS); }

"+="                { return setTokenData(ADDASS); }
"-="                { return setTokenData(SUBASS); }
"*="                { return setTokenData(MULASS); }
"/="                { return setTokenData(DIVASS); }

"++"                { return setTokenData(INC); }
"--"                { return setTokenData(DEC); }

"="                 { return setTokenData(ASS); }
"+"                 { return setTokenData(ADDOP); }
"-"                 { return setTokenData(SUBOP); }
"*"                 { return setTokenData(MULOP); }
"/"                 { return setTokenData(DIVOP); }
"%"                 { return setTokenData(MODOP); }
"?"                 { return setTokenData(QUEOP); }

"and"               { return setTokenData(AND); }
"not"               { return setTokenData(NOT); }
"or"                { return setTokenData(OR);  }

"."                 { return setTokenData(ACC); }

"bool"              { return setTokenData(BOOL);   }
"break"             { return setTokenData(BREAK);  }
"char"              { return setTokenData(CHAR);   }
"else"              { return setTokenData(ELSE);   }
"if"                { return setTokenData(IF);     }
"int"               { return setTokenData(INT);    }
"record"            { return setTokenData(RECORD); }
"return"            { return setTokenData(RETURN); }
"static"            { return setTokenData(STATIC); }
"while"             { return setTokenData(WHILE);  }

";"                 { return setTokenData(SEMI); }
":"                 { return ':'; }
","                 { return ','; }
"("                 { return '('; }
")"                 { return ')'; }
"["                 { return setTokenData(LBRACKET); }
"]"                 { return setTokenData(RBRACKET); }
"{"                 { return setTokenData(LBRACE);   }
"}"                 { return setTokenData(RBRACE);   }

{W}                 ;
{N}                 { ++lineno; }

{L}{I}*             { return setTokenData(ID); }
{D}+                { return setTokenData(NUMCONST); }
L?'"\\"?{C}'        { return setTokenData(CHARCONST); }

"//"                BEGIN(COMMENT);
<COMMENT>[^\n]      ;
<COMMENT>"\n"        { ++lineno; BEGIN(INITIAL); }

.                   { return setTokenData(INVALID); } 

%%

int setTokenData(int tokenClass) {
    yylval.tokenData = new TokenData;
    yylval.tokenData->lineno = lineno;
    yylval.tokenData->tokenClass = tokenClass;
    yylval.tokenData->tokenString = strdup(yytext);
    yylval.tokenData->tokenStringRep = strdup(yytext);
    
    switch (tokenClass) {
    case BOOLCONST: 
        if (strcmp("true", yytext) == 0) {
            yylval.tokenData->bval = true;
        } else {
            yylval.tokenData->bval = false;
        }
        break;
    case ID: {
            void* data = symbolTable.lookup(yylval.tokenData->tokenString);

            if (data != NULL) {
                printf("Found an ID that is actually a record: %s line %d\n", yylval.tokenData->tokenString, lineno);
                yylval.tokenData->tokenClass = RECTYPE;
            } else {
                ;
            }
            // Check if an ID is present in recordTable
            //This would mean this ID refers to a record type, not a normal identifier.
            // map<string, TokenData*>::iterator it = recordTable.find(yylval.tokenData->tokenString);
            // if (it != recordTable.end()) {
            //     yylval.tokenData->tokenClass = RECTYPE;
            // }
        }
        break;
    case NUMCONST:
        yylval.tokenData->ival = atoi(yylval.tokenData->tokenString);
        break;
    case CHARCONST:
        yylval.tokenData->cval = formatCharConst(yylval.tokenData->tokenString);
        break;
    case AND:
        yylval.tokenData->tokenClass = AND;
        yylval.tokenData->tokenStringRep = "AND";
        break;
    case OR:
        yylval.tokenData->tokenClass = OR;
        yylval.tokenData->tokenStringRep = "OR";
        break;
    case NOT:
        yylval.tokenData->tokenClass = NOT;
        yylval.tokenData->tokenStringRep = "NOT";
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
    case LESS:
        yylval.tokenData->relopval = LESS;
        yylval.tokenData->tokenClass = RELOP;
        yylval.tokenData->relopString = "<";
        break;
    case GRTR:
        yylval.tokenData->relopval = GRTR;
        yylval.tokenData->tokenClass = RELOP;
        yylval.tokenData->relopString = ">";
        break;
    case ADDASS:
        yylval.tokenData->tokenStringRep = "ADDASS";
        break;
    case SUBASS:
        yylval.tokenData->tokenStringRep = "SUBASS";
        break;
    case MULASS:
        yylval.tokenData->tokenStringRep = "MULASS";
        break;
    case DIVASS:
        yylval.tokenData->tokenStringRep = "DIVASS";
        break;
    case INC:
        yylval.tokenData->tokenStringRep = "INC";
        break;
    case DEC:
        yylval.tokenData->tokenStringRep = "DEC";
        break;
    case BOOL:
        yylval.tokenData->tokenClass = BOOL;
        yylval.tokenData->tokenStringRep = "BOOL";
        break;
    case BREAK:
        yylval.tokenData->tokenClass = BREAK;
        yylval.tokenData->tokenStringRep = "BREAK";
        break;
    case CHAR:
        yylval.tokenData->tokenClass = CHAR;
        yylval.tokenData->tokenStringRep = "CHAR";
        break;
    case ELSE:
        yylval.tokenData->tokenClass = ELSE;
        yylval.tokenData->tokenStringRep = "ELSE";
        break;
    case IF:
        yylval.tokenData->tokenClass = IF;
        yylval.tokenData->tokenStringRep = "IF";
        break;
    case INT:
        yylval.tokenData->tokenClass = INT;
        yylval.tokenData->tokenStringRep = "INT";
        break;
    case RECORD:
        yylval.tokenData->tokenClass = RECORD;
        yylval.tokenData->tokenStringRep = "RECORD";
        break;
    case RETURN:
        yylval.tokenData->tokenClass = RETURN;
        yylval.tokenData->tokenStringRep = "RETURN";
        break;
    case STATIC:
        yylval.tokenData->tokenClass = STATIC;
        yylval.tokenData->tokenStringRep = "STATIC";
        break;
    case WHILE:
        yylval.tokenData->tokenClass = WHILE;
        yylval.tokenData->tokenStringRep = "WHILE";
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
