%{

#include <iostream>
#include "scanType.h"

using namespace std;

extern "C" int yylex();
extern "C" int yyparse();

void yyerror(const char *s);
const char* prefix();

extern "C" FILE *yyin;
extern "C" char *yytext;

extern int lineno;

void log(const char *msg) {
    printf("Line %d: %s\n", lineno, msg);
}

%}

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

%token <tokenData> SUMOP
%token ADD
%token SUB

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
%token <tokenData> INT
%token <tokenData> RECORD
%token <tokenData> RETURN
%token <tokenData> STATIC
%token <tokenData> WHILE

%union {
    TokenData *tokenData;
}

%%

program: declarationList
    ;

declarationList: declarationList declaration
               | declaration
               ;

declaration: varDeclaration
           | funDeclaration
           | recDeclaration
           ;

recDeclaration: RECORD ID '{' localDeclarations '}'   {
                    printf("Got a record, id %s\n", $2->tokenString);
              }
              ;

scopedVarDeclarations: scopedTypeSpecifier varDeclList ';'
                     ;

varDeclaration: typeSpecifier varDeclList ';'
              ;

varDeclList: varDeclList ',' varDeclInitialize   { log("Got a var declaration list"); }
           | varDeclInitialize
           ;
varDeclInitialize: varDeclId
                 | varDeclId ':' simpleExpression
                 ;
varDeclId: ID
         | ID '[' NUMCONST ']'
         ;

scopedTypeSpecifier: STATIC typeSpecifier
                   | typeSpecifier
                   ;

typeSpecifier: INT
             | BOOL
             | CHAR
             ;

funDeclaration: typeSpecifier ID '(' params ')' statement { 
                    printf("Got a function id %s\n", $2->tokenString);
              } 
              | ID '(' params ')' statement {
                    printf("Got function without type, id %s\n", $1->tokenString);
              }
              ;

params: paramList
      |
      ;

paramList: paramList ';' paramTypeList
         | paramTypeList
         ;

paramTypeList: typeSpecifier paramIdList
             ;

paramIdList: paramIdList ',' paramId
           | paramId
           ;

paramId: ID
       | ID '[' ']'
       ;

statement: matched
         | unmatched
         ;

matched: IF '(' simpleExpression ')' matched ELSE matched       {
            log("Got a fully matched if statement");
       }
       | WHILE '(' simpleExpression ')' matched                 {
             log("Got a while statement");
       }
       | otherstatements
       ;

unmatched: IF '(' simpleExpression ')' matched                  {
              log("Got an if statement without an else");
         }
         | IF '(' simpleExpression ')' unmatched                {
              log("Got an if statement with an inner unmatched statement.");
         }
         | IF '(' simpleExpression ')' matched ELSE unmatched   { 
              log("Got an if statement with an inner matched statement but an unmatched statement within the else block.");
         }
         ;

otherstatements: expressionStmt
         | compoundStmt
         | returnStmt
         | breakStmt
         ;

compoundStmt: '{' localDeclarations statementList  '}'
            ;

localDeclarations: localDeclarations scopedVarDeclarations
                 | 
                 ;

statementList: statementList statement
             |
             ;

expressionStmt: expression ';' 
              | ';'
              ;

returnStmt: RETURN ';'                  { log("Got a simple return statement"); }
          | RETURN expression ';'       { log("Got a return statement with an expression in it."); }
          ;
breakStmt: BREAK ';'
         ;

expression: mutable '=' expression        { log("Got an assignment statement"); }
          | mutable ADDASS expression
          | mutable SUBASS expression
          | mutable MULASS expression
          | mutable DIVASS expression
          | mutable INC
          | mutable DEC
          | simpleExpression
          ;

simpleExpression: simpleExpression OR andExpression {
                    // $$ = $1 && $3
                }
                | andExpression
                ;

andExpression: andExpression AND unaryRelExpression
             | unaryRelExpression
             ;
unaryRelExpression: NOT unaryRelExpression
                  | relExpression
                  ;
relExpression: sumExpression RELOP sumExpression
             | sumExpression
             ;
sumExpression: sumExpression sumop term
             | term
             ;
sumop: '+'
     | '-'
     ;
term: term mulop unaryExpression
    | unaryExpression
    ;
mulop: '*'
     | '/'
     | '%'
     ;
unaryExpression: unaryop unaryExpression
               | factor
               ;
unaryop: '-'
       | '*'
       | '?'
       ;
factor: immutable
      | mutable
      ;
mutable: ID
       | ID '[' expression ']'
       | mutable '.' ID
       ;
immutable: '(' expression ')'
         | call
         | constant
         ;

call: ID '(' args ')'             { printf("function call %s\n", $1->tokenString); }

args: argList
    |
    ;
argList: argList ',' expression
       | expression
       ;
constant: NUMCONST
        | CHARCONST
        | BOOLCONST
        | INVALID
        {
            yyerrok;
            yyerror("Match error");
        }
        ;

%%

int main (int argc, char **argv) {
    printf(""); // WTF
    if (argc > 1) {
        FILE* f = fopen(argv[1], "r");
        if (!f) {
            cout << "Couldn't open the input file: " << argv[1] << endl;
            return EXIT_FAILURE;
        }
        yyin = f;
    } else {
        yyin = stdin;
    }
    
    while (!feof(yyin)) {
        yyparse();
    }

    return EXIT_SUCCESS;
}

const char* prefix() {
    static char message[64];
    sprintf(message, "Line %d Token:", lineno);
    return message;
}

void yyerror(const char *s) {
   printf("ERROR(%d): %s: \"%s\"\n", lineno, s, yytext); 
}

