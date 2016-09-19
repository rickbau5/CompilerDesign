%{

#include <iostream>
#include "scanType.h"
#include "util.h"

using namespace std;

extern "C" int yylex();
extern "C" int yyparse();

void yyerror(const char *s);
const char* prefix();

Node* newNode(nodes::NodeType, TokenData*);
Node* addSibling(Node*, Node*);
Node* addChild(Node*, Node*);
Node* addChild(Node*, Node*, int);

extern "C" FILE *yyin;
extern "C" char *yytext;

extern int lineno;

void log(const char *msg) {
    printf("Line %d: %s\n", lineno, msg);
}

Node* root; 

#define YYDEBUG 1

%}

%debug

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

%type <nodePtr> declarationList declaration varDeclaration varDeclList scopedVarDeclarations varDeclInitialize varDeclId funDeclaration recDeclaration statement matched unmatched otherstatements compoundStmt localDeclarations statementList expressionStmt expression simpleExpression andExpression unaryRelExpression relExpression sumExpression term unaryExpression factor params paramList paramTypeList paramIdList paramId typeSpecifier scopedTypeSpecifier constant mutable 

%union {
    TokenData *tokenData;
    Node *nodePtr;
}

%%

program: declarationList        { root = $1; } 
    ;

declarationList: declarationList declaration    {
                    Node* ret = addSibling($1, $2);
                    $$ = ret;
               }
               | declaration                    {
                    $$ = $1;
               }
               ;

declaration: varDeclaration     { $$ = $1; }
           | funDeclaration     { $$ = $1; }
           | recDeclaration     { $$ = $1; }
           | error ';'          { $$ = NULL; printf("error %d\n", lineno);  }
           ;

recDeclaration: RECORD ID '{' localDeclarations '}'   {
                    printf("Got a record, id %s\n", $2->tokenString);
              }
              ;

scopedVarDeclarations: scopedTypeSpecifier varDeclList ';'  {
                        $$ = $2;
                     }
                     ;

varDeclaration: typeSpecifier varDeclList ';'   { $$ = $2; }
              ;

varDeclList: varDeclList ',' varDeclInitialize   { 
                $$ = addSibling($1, $3);
           }
           | varDeclInitialize                   { $$ = $1; }
           ;
varDeclInitialize: varDeclId                        {
                    Node* node = newNode(nodes::Variable, NULL);
                    $$ = node;
                 }
                 | varDeclId ':' simpleExpression   {
                    
                 }
                 ;

varDeclId: ID                   { $$ = newNode(nodes::Identifier, $1); }
         | ID '[' NUMCONST ']'  { 
            Node* node = newNode(nodes::Identifier, $1);
            addChild(node, newNode(nodes::Constant, $3));
            $$ = node;
         } 
         ;

scopedTypeSpecifier: STATIC typeSpecifier   { $2->isStatic = true; $$ = $2 }
                   | typeSpecifier          { $$ = $1; }
                   ;

typeSpecifier: INT      { $$ = newNode(nodes::Type, $1); }
             | BOOL     { $$ = newNode(nodes::Type, $1); }
             | CHAR     { $$ = newNode(nodes::Type, $1); }
             ;

funDeclaration: typeSpecifier ID '(' params ')' statement { 
                    Node* node = newNode(nodes::Function, $2);
                    node->returnType = $1->tokenString;
                    addChild(node, $4);
                    $$ = node;
              } 
              | ID '(' params ')' statement {
                    Node* node = newNode(nodes::Function, $1);
                    node->returnType = "void";
                    addChild(node, $3);
                    addChild(node, $5);
                    $$ = node;
              }
              ;

params: paramList       { $$ = $1; }
      |                 { $$ = NULL; }
      ;

paramList: paramList ';' paramTypeList      { 
            Node* ret = addSibling($1, $3);
            $$ = ret;
         }
         | paramTypeList    { $$ = $1; }
         ;

paramTypeList: typeSpecifier paramIdList    {
                Node* node = newNode(nodes::ParamList, NULL);
                node->lineno = $1->lineno;
                node->type = $1->tokenString;
                for(Node* s = $2; s != NULL; s = s->sibling)
                    s->type = node->type;
                addChild(node, $2);
                $$ = node;
             }
             ;

paramIdList: paramIdList ',' paramId        {
            Node* ret = addSibling($1, $3);
            $$ = ret;
           }
           | paramId        { $$ = $1; }
           ;

paramId: ID             { $$ = newNode(nodes::Parameter, $1); }
       | ID '[' ']'     { $$ = newNode(nodes::Parameter, $1); }
       ;

statement: matched      { $$ = $1; }
         | unmatched    { $$ = NULL; }
         ;

matched: IF '(' simpleExpression ')' matched ELSE matched       {
            log("Got a fully matched if statement");
            $$ = NULL;
       }
       | WHILE '(' simpleExpression ')' matched                 {
            log("Got a while statement");
            $$ = NULL;
       }
       | otherstatements    { $$ = $1; }
       ;

unmatched: IF '(' simpleExpression ')' matched                  {
            log("Got an if statement without an else");
            $$ = NULL;
         }
         | IF '(' simpleExpression ')' unmatched                {
            log("Got an if statement with an inner unmatched statement.");
            $$ = NULL;
         }
         | IF '(' simpleExpression ')' matched ELSE unmatched   { 
            log("Got an if statement with an inner matched statement but an unmatched statement within the else block.");
            $$ = NULL;
         }
         ;

otherstatements: expressionStmt     { $$ = NULL; }
         | compoundStmt             { $$ = $1; }
         | returnStmt               { $$ = NULL; }
         | breakStmt                { $$ = NULL; }
         ;

compoundStmt: '{' localDeclarations statementList  '}'  {
                Node* node = newNode(nodes::Compound, NULL);
                node->lineno = lineno; 
                addChild(node, $2);
                addChild(node, $3);
                $$ = node;
            }
            ;

localDeclarations: localDeclarations scopedVarDeclarations  {
                    $$ = addSibling($1, $2); 
                 }
                 |  { $$ = NULL; }
                 ;

statementList: statementList statement  {
                $$ = addSibling($1, $2); 
             }
             |      { $$ = NULL; }
             ;

expressionStmt: expression ';'  { $$ = $1; } 
              | ';'             { $$ = NULL; }  
              ;

returnStmt: RETURN ';'                  { log("Got a simple return statement"); }
          | RETURN expression ';'       { log("Got a return statement with an expression in it."); }
          ;
breakStmt: BREAK ';'
         ;

expression: mutable '=' expression      { $$ = NULL; }
          | mutable ADDASS expression   { $$ = NULL; } 
          | mutable SUBASS expression   { $$ = NULL; }  
          | mutable MULASS expression   { $$ = NULL; } 
          | mutable DIVASS expression   { $$ = NULL; } 
          | mutable INC                 { $$ = NULL; } 
          | mutable DEC                 { $$ = NULL; } 
          | simpleExpression            { $$ = $1; }
          ;

simpleExpression: simpleExpression OR andExpression { $$ = NULL; }
                | andExpression                     { $$ = $1; }
                ;
andExpression: andExpression AND unaryRelExpression { $$ = NULL; }
             | unaryRelExpression                   { $$ = $1; }
             ;
unaryRelExpression: NOT unaryRelExpression          { $$ = NULL; }
                  | relExpression                   { $$ = $1; }
                  ;
relExpression: sumExpression RELOP sumExpression    { $$ = NULL; }
             | sumExpression                        { $$ = $1; }
             ;
sumExpression: sumExpression sumop term     { $$ = NULL; }
             | term                         { $$ = $1; }
             ;
sumop: '+'
     | '-'
     ;
term: term mulop unaryExpression    { $$ = NULL; }
    | unaryExpression               { $$ = $1; }
    ;
mulop: '*'
     | '/'
     | '%'
     ;
unaryExpression: unaryop unaryExpression    { $$ = NULL; }
               | factor                     { $$ = $1; }
               ;
unaryop: '-'
       | '*'
       | '?'
       ;
factor: immutable   { $$ = NULL; }
      | mutable     { $$ = $1; }
      ;
mutable: ID                     { 
            $$ = newNode(nodes::Identifier, $1);
       }
       | ID '[' expression ']'  {
           //  Node* t = newNode(nodes::Identifier, $1);
           //  addChild(t, expression);
       }
       | mutable '.' ID
       ;
immutable: '(' expression ')'
         | call
         | constant
         ;

call: ID '(' args ')' 

args: argList
    |
    ;
argList: argList ',' expression
       | expression
       ;
constant: NUMCONST  {
            $$ = newNode(nodes::Constant, $1);
        }
        | CHARCONST {
            $$ = newNode(nodes::Constant, $1);
        }
        | BOOLCONST {
            $$ = newNode(nodes::Constant, $1);
        }
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

    printf("There are %d nodes.\n", countNodes(root));

    prettyPrintTree(root);

    return EXIT_SUCCESS;
}

Node* newNode(nodes::NodeType type, TokenData* token) {
    Node* node = new Node;
    node->nodeType = type;
    if (token != NULL) {
        node->tokenString = strdup(token->tokenString);
    }
    node->type = toString(type);

    node->sibling = NULL;
    
    for (int i = 0; i < MAX_CHILDREN; i++)
        node->children[i] = NULL;

    if (token != NULL)
        node->lineno = token->lineno;

    return node;
}

Node* addSibling(Node* existing, Node* addition) {
    if (existing != NULL) {
        Node* t = existing;
        while (t->sibling != NULL) {
            t = t->sibling;
        }
        printf("Attaching %s to %s\n", t->type, addition->type);
        addition->siblingIndex = t->siblingIndex + 1;
        t->sibling = addition;
        return existing;
    } else {
        return addition;
    }
}

Node* addChild(Node* parent, Node* child) {
    addChild(parent, child, parent->numChildren);
    return parent;
}

Node* addChild(Node* parent, Node* child, int idx) {
    if (idx < parent->numChildren) {
        fprintf(stderr, "Index is below current child count for [%s]->[%s], index %d, but count is %d!\n", parent->type, child->type, idx, parent->numChildren);
    } else if (idx >= MAX_CHILDREN) {
        fprintf(stderr, "Trying to add child [%s] to [%s] but %d exceeds max children %d!\n", parent->type, child->type, idx, MAX_CHILDREN);
    } else {
        parent->children[idx] = child;
        parent->numChildren++;
    }

    return parent;
}

const char* prefix() {
    static char message[64];
    sprintf(message, "Line %d Token:", lineno);
    return message;
}

void yyerror(const char *s) {
    printf("ERROR(%d): %s: \"%s\"\n", lineno, s, yytext); 
}

