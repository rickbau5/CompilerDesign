%{

#include <iostream>
#include "scanType.h"
#include "util.h"

#define MAX_ERRORS 256
#define YYDEBUG 1

using namespace std;

extern "C" int yylex();
extern "C" int yyparse();

void yyerror(const char *s);
const char* prefix();

Node* newNode(nodes::NodeType, TokenData*);
Node* errorNode(TokenData*);
Node* addSibling(Node*, Node*);
Node* addChild(Node*, Node*);
Node* addChild(Node*, Node*, int);

void printErrors();

extern "C" FILE *yyin;
extern "C" char *yytext;

extern int lineno;

void log(const char *msg) {
    printf("Line %d: %s\n", lineno, msg);
}

Node* root; 
Node* errors[MAX_ERRORS];
int numErrors = 0;

%}

%debug

%token <tokenData> INVALID

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

%type <tokenData> sumop
%type <tokenData> mulop
%type <tokenData> unaryop
%token <tokenData> ADDOP
%token <tokenData> SUBOP
%token <tokenData> MULOP
%token <tokenData> DIVOP
%token <tokenData> MODOP
%token <tokenData> QUEOP

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

%token <tokenData> LBRACE
%token <tokenData> RBRACE
%token <tokenData> LBRACKET
%token <tokenData> RBRACKET
%token <tokenData> ACC

%type <nodePtr> declarationList declaration varDeclaration varDeclList scopedVarDeclarations varDeclInitialize varDeclId funDeclaration recDeclaration returnStmt breakStmt statement matched unmatched otherstatements compoundStmt localDeclarations statementList expressionStmt expression simpleExpression andExpression unaryRelExpression relExpression sumExpression term unaryExpression factor params paramList paramTypeList paramIdList paramId typeSpecifier scopedTypeSpecifier constant mutable immutable call args argList

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
           | error ';'          { yyerrok; yyclearin; $$ = errorNode(NULL); printf("error %d\n", lineno);  }
           ;

recDeclaration: RECORD ID LBRACE localDeclarations RBRACE   {
                    printf("Got a record, id %s\n", $2->tokenString);
              }
              ;

scopedVarDeclarations: scopedTypeSpecifier varDeclList ';'  {
                        // For declarations in statements, loop through siblings and attach type and static info
                        for (Node* decl = $2; decl != NULL; decl = decl->sibling) {
                            decl->type = $1->tokenString;
                            decl->isStatic = $1->tokenString;
                        }
                        $$ = $2;
                     }
                     ;

varDeclaration: typeSpecifier varDeclList ';'  {
                 $2->type = $1->tokenString;
                 for (Node *s = $2->sibling; s != NULL; s = s->sibling)
                    s->type = $1->tokenString;
                 $$ = $2;
              }
              ;

varDeclList: varDeclList ',' varDeclInitialize   { 
                $$ = addSibling($1, $3);
           }
           | varDeclInitialize                   { $$ = $1; }
           ;

varDeclInitialize: varDeclId                        {
                    $$ = $1;
                 }
                 | varDeclId ':' simpleExpression   {
                    
                 }
                 ;

varDeclId: ID                   { $$ = newNode(nodes::Identifier, $1); }
         | ID LBRACKET NUMCONST RBRACKET { 
            Node* node = newNode(nodes::Identifier, $1);
            node->arraySize = atoi($3->tokenString);
            node->isArray = true;
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
                    //addChild(node, $6);
                    $$ = node;
              } 
              | ID '(' params ')' statement {
                    Node* node = newNode(nodes::Function, $1);
                    node->returnType = "void";
                    // addChild(node, $3);
                    // addChild(node, $5);
                    $$ = node;
              }
              ;

params: paramList       {
            int idx = -1;
            for(Node* s = $1; s != NULL; s = s->sibling)
                s-> siblingIndex = idx++;
            $$ = $1;
      }
      |                 { $$ = newNode(nodes::Empty, NULL); }
      ;

paramList: paramList ';' paramTypeList      { 
            Node* ret = addSibling($1, $3);
            $$ = ret;
         }
         | paramTypeList    { $$ = $1; }
         ;

paramTypeList: typeSpecifier paramIdList    {
                Node* node = $2;
                node->lineno = $1->lineno;
                node->type = $1->tokenString;
                for(Node* s = $2; s != NULL; s = s->sibling)
                    s->type = node->type;
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
       | ID LBRACKET RBRACKET     { $$ = newNode(nodes::Parameter, $1); $$->isArray = true; }
       ;

statement: matched      { $$ = $1; }
         | unmatched    { $$ = errorNode(NULL); }
         ;

matched: IF '(' simpleExpression ')' matched ELSE matched       {
            Node* node = newNode(nodes::IfStatement, $1);
            addChild(node, $3);
            addChild(node, $5);
            addChild(node, $7);
            $$ = node;
       }
       | WHILE '(' simpleExpression ')' matched                 {
            Node* node = newNode(nodes::WhileStatement, $1);
            printf("got a while statement.\n");
            addChild(node, $3);
            addChild(node, $5);
            $$ = node;
       }
       | otherstatements    { $$ = $1; }
       ;

unmatched: IF '(' simpleExpression ')' matched                  {
            log("Got an if statement without an else");
            $$ = errorNode($1);
         }
         | IF '(' simpleExpression ')' unmatched                {
            log("Got an if statement with an inner unmatched statement.");
            $$ = errorNode($1);
         }
         | IF '(' simpleExpression ')' matched ELSE unmatched   { 
            log("Got an if statement with an inner matched statement but an unmatched statement within the else block.");
            $$ = errorNode($1);
         }
         ;

otherstatements: expressionStmt     { $$ = $1; }
         | compoundStmt             { $$ = $1; }
         | returnStmt               { $$ = $1; }
         | breakStmt                { $$ = $1; }
         ;

compoundStmt: LBRACE localDeclarations statementList  RBRACE  {
                Node* node = newNode(nodes::Compound, $1);
                addChild(node, $2);
                addChild(node, $3);
                for(int i = 0; i < node->numChildren; i++) 
                    if (node->children[i] == NULL) printf("Null child\n");
                    else printf("Child %d: %s\n", i, stringifyNode(node->children[i]));
                $$ = node;
            }
            ;

localDeclarations: localDeclarations scopedVarDeclarations  {
                    $$ = addSibling($1, $2); 
                 }
                 |  { ; }
                 ;

statementList: statementList statement  {
                $$ = addSibling($1, $2); 
             }
             |  { ; } 
             ;

expressionStmt: expression ';'  { $$ = $1; } 
              | ';'             { ; }  
              ;

returnStmt: RETURN ';'                  { $$ = errorNode($1); log("Got a simple return statement"); }
          | RETURN expression ';'       { $$ = errorNode($1); log("Got a return statement with an expression in it."); }
          
breakStmt: BREAK ';'                    { $$ = errorNode($1); } 
         ;

expression: mutable ASS expression      {
            Node* node = newNode(nodes::Assignment, $2);
            addChild(node, $1);
            addChild(node, $3);
            $$ = node;
          }
          | mutable ADDASS expression   { $$ = errorNode($2); } 
          | mutable SUBASS expression   { $$ = errorNode($2); }  
          | mutable MULASS expression   { $$ = errorNode($2); } 
          | mutable DIVASS expression   { $$ = errorNode($2); } 
          | mutable INC                 { $$ = errorNode($2); } 
          | mutable DEC                 { $$ = errorNode($2); } 
          | simpleExpression            { $$ = $1; }
          ;

simpleExpression: simpleExpression OR andExpression { $$ = errorNode($2); }
                | andExpression                     { $$ = $1; }
                ;
andExpression: andExpression AND unaryRelExpression { $$ = errorNode($2); }
             | unaryRelExpression                   { $$ = $1; }
             ;
unaryRelExpression: NOT unaryRelExpression          { $$ = errorNode($1); }
                  | relExpression                   { $$ = $1; }
                  ;
relExpression: sumExpression RELOP sumExpression    { 
                Node* node = newNode(nodes::Operator, $2);
                addChild(node, $1);
                addChild(node, $3);
                $$ = node;
             }
             | sumExpression                        { $$ = $1; }
             ;
sumExpression: sumExpression sumop term     {
                Node* node = newNode(nodes::Operator, $2);
                addChild(node, $1);
                addChild(node, $3);
                $$ = node;
             }
             | term                         { $$ = $1; }
             ;

sumop: ADDOP        
     | SUBOP
     ;

term: term mulop unaryExpression    {
        Node* node = newNode(nodes::Operator, $2);
        addChild(node, $1);
        addChild(node, $3);
        $$ = node;
    }
    | unaryExpression               { $$ = $1; }
    ;

mulop: MULOP
     | DIVOP
     | MODOP
     ;

unaryExpression: unaryop unaryExpression    { $$ = errorNode($1); }
               | factor                     { $$ = $1; }
               ;
unaryop: SUBOP
       | MULOP
       | QUEOP
       ;
factor: immutable   { $$ = $1; }
      | mutable     { $$ = $1; }
      | error       { $$ = errorNode(NULL); }
      ;
mutable: ID                     { 
            $$ = newNode(nodes::Identifier, $1);
       }
       | ID LBRACKET expression RBRACKET  {
            Node* t = newNode(nodes::Operator, $2);
            addChild(t, newNode(nodes::Identifier, $1));
            addChild(t, $3);
            $$ = t;
       }
       | mutable ACC ID         { 
            Node* node = newNode(nodes::Operator, $2);
            addChild(node, $1);
            addChild(node, newNode(nodes::Identifier, $3));
            $$ = node;
       }
       ;
immutable: '(' expression ')'   { $$ = $2; }
         | call                 { $$ = $1; }
         | constant             { $$ = $1; }
         ;

call: ID '(' args ')'           { $$ = newNode(nodes::FunctionCall, $1); addChild($$, $3); } 
    ;

args: argList                   { $$ = $1; }
    |                           { $$ = newNode(nodes::Empty, NULL); }
    ;
argList: argList ',' expression { $$ = addSibling($1, $3); }
       | expression             { $$ = $1; }
       ;
constant: NUMCONST  {
            Node* n = newNode(nodes::Constant, $1);
            $$ = n; 
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
            yyclearin;
            yyerror("Match error");
            $$ = errorNode($1);
        }
        ;

%%

bool override = true;

int main (int argc, char **argv) {
    printf(""); // WTF
    if (override) {
        FILE* f = fopen("test.c-", "r");
        yyin = f;
    } else {
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
    }
    
    while (!feof(yyin)) {
        yyparse();
    }

    prettyPrintTree(root);

    printf("Number of errors: %d\n", numErrors);
    if (numErrors > 0) 
        printErrors();

    return EXIT_SUCCESS;
}

Node* newNode(nodes::NodeType type, TokenData* token) {
    printf("creating node %s\n", toString(type)); 
    Node* node = new Node;
    node->nodeType = type;
    if (token != NULL) {
        node->tokenString = strdup(token->tokenString);
    }
    node->type = toString(type);

    node->sibling = nullptr;
    node->siblingIndex = -1;
    
    for (int i = 0; i < MAX_CHILDREN; i++)
        node->children[i] = NULL;

    if (token != NULL)
        node->lineno = token->lineno;

    return node;
}

Node* errorNode(TokenData* data) {
    Node* err = newNode(nodes::Error, data);
    errors[numErrors++] = err;    
    return err;
}

void printErrors() {
    int i = 0;
    for (Node* err = errors[i]; err != NULL; err = errors[++i]) {
       printf("Error %d of %d at line %d: %s\n", i + 1, numErrors, err->lineno, err->tokenString); 
    }
}

Node* addSibling(Node* existing, Node* addition) {
    printf("Add sibling call: %s -> %s\n", stringifyNode(existing), stringifyNode(addition));
    if (existing != NULL) {
        if (addition == NULL) return existing;
        Node* t = existing;
        if (t->sibling == NULL) printf("yeah\n");
        while (t->sibling != NULL) {
            printf("Looking at node %s\n", stringifyNode(t));
            t = t->sibling;
        }
        addition->siblingIndex = t->siblingIndex + 1;
        t->sibling = addition;
        printf("Attched sibling %s->%s\n", t->tokenString, addition->tokenString);
        return existing;
    } else {
        if (addition == NULL)
            return existing;
        return addition;
    }
}

Node* addChild(Node* parent, Node* child) {
    addChild(parent, child, parent->numChildren);
    return parent;
}

Node* addChild(Node* parent, Node* child, int idx) {
    if (idx < parent->numChildren) {
        printf("Index is below current child count for [%s]->[%s], index %d, but count is %d!\n", parent->type, child->type, idx, parent->numChildren);
    } else if (idx >= MAX_CHILDREN) {
        printf("Trying to add child [%s] to [%s] but %d exceeds max children %d!\n", parent->type, child->type, idx, MAX_CHILDREN);
    } else {
        parent->children[idx] = child;
        if (child == NULL) 
            printf("null child for parent %s\n", stringifyNode(parent));
        printf("Child: %s\n", toString(child->nodeType));
        const char* str = stringifyNode(child);
        printf("Child: %s\n", str);
        printf("Added child %s to %s at index %d\n", str, stringifyNode(parent), idx);
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

