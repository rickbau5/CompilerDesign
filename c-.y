%{

#include "c-.h"
#include "scanType.h"
#include "util.h"

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

void log(const char *msg) {
    printf("Line %d: %s\n", lineno, msg);
}

Node* root;
Node* errors[MAX_ERRORS];
int numErrors;

int currNodeId = 0;

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
%token <tokenData> SEMI
%token <tokenData> ACC

%type <nodePtr> declarationList declaration varDeclaration varDeclList scopedVarDeclarations varDeclInitialize varDeclId funDeclaration recDeclaration returnStmt breakStmt statement matched unmatched otherstatements compoundStmt localDeclarations statementList expressionStmt expression simpleExpression andExpression unaryRelExpression relExpression sumExpression term unaryExpression factor params paramList paramTypeList paramIdList paramId constant mutable immutable call args argList

%type <tokenData> typeSpecifier scopedTypeSpecifier 

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
           | recDeclaration     { $$ = NULL; }
           | error SEMI         { yyerrok; yyclearin; $$ = errorNode($2); printf("error %d\n", lineno);  }
           ;

recDeclaration: RECORD ID LBRACE localDeclarations RBRACE   {
                    printf("Got a record, id %s\n", $2->tokenString);
              }
              ;

scopedVarDeclarations: scopedTypeSpecifier varDeclList SEMI  {
                        // For declarations in statements, loop through siblings and attach type and static info
                        for (Node* decl = $2; decl != NULL; decl = decl->sibling) {
                            decl->type = $1->tokenString;
                            decl->isStatic = $1->isStatic;
                        }
                        $$ = $2;
                     }
                     ;

varDeclaration: typeSpecifier varDeclList SEMI  {
                Node* n = $2;
                for (Node *s = n; s != NULL; s = s->sibling) {
                    s->nodeType = nodes::Variable;
                    s->type = $1->tokenString;
                }
                $$ = n
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
                    $$ = addChild($1, $3);                    
                 }
                 ;

varDeclId: ID                   { $$ = newNode(nodes::Variable, $1); }
         | ID LBRACKET NUMCONST RBRACKET { 
            Node* node = newNode(nodes::Identifier, $1);
            node->arraySize = atoi($3->tokenString);
            node->isArray = true;
            $$ = node;
         } 
         ;

scopedTypeSpecifier: STATIC typeSpecifier   { $2->isStatic = true;  $$ = $2; }
                   | typeSpecifier          { $1->isStatic = false; $$ = $1; }
                   ;

typeSpecifier: INT
             | BOOL
             | CHAR
             ;

funDeclaration: typeSpecifier ID '(' params ')' statement { 
                    Node* node = newNode(nodes::Function, $2);
                    node->returnType = $1->tokenString;
                    addChild(node, $4);
                    addChild(node, $6);
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

params: paramList       {
            int idx = 0;
            for(Node* s = $1->sibling; s != NULL; s = s->sibling)
                s-> siblingIndex = idx++;
            $$ = $1;
      }
      |                 { $$ = NULL; }
      ;

paramList: paramList SEMI paramTypeList      { 
            $$ = addSibling($1, $3);
         }
         | paramTypeList    { $$ = $1; }
         ;

paramTypeList: typeSpecifier paramIdList    {
                Node* node = $2;
                for (Node* s = node; s != NULL; s = s->sibling)
                    s->type = $1->tokenString;
                $$ = $2; 
             }
             ;

paramIdList: paramIdList ',' paramId        {
                $$ = addSibling($1, $3);
           }
           | paramId        { $$ = $1; }
           ;

paramId: ID                       { $$ = newNode(nodes::Parameter, $1); }
       | ID LBRACKET RBRACKET     { $$ = newNode(nodes::Parameter, $1); $$->isArray = true; }
       ;

statement: matched      { $$ = $1; }
         | unmatched    { $$ = errorNode(NULL); }
         ;

matched: IF '(' simpleExpression ')' matched ELSE matched       {
            // Node* node = newNode(nodes::IfStatement, $1);
            // addChild(node, $3);
            // addChild(node, $5);
            // addChild(node, $7);
            // $$ = node;
            $$ = NULL;
       }
       | WHILE '(' simpleExpression ')' matched                 {
            Node* node = newNode(nodes::WhileStatement, $1);
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
                addChild(node, $2, 0);
                addChild(node, $3, 1);
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
             |  { $$ = NULL; } 
             ;

expressionStmt: expression SEMI  { $$ = $1; } 
              | SEMI             { ; }  
              ;

returnStmt: RETURN SEMI                  { $$ = newNode(nodes::Return, $1); }
          | RETURN expression SEMI       {
                Node* node = newNode(nodes::ReturnStatement, $1);
                addChild(node, $2);
                $$ = node;
          }
          ;
breakStmt: BREAK SEMI                    { $$ = errorNode($1); } 
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

simpleExpression: simpleExpression OR andExpression {
                    Node* node = newNode(nodes::Operator, $2);
                    addChild(node, $1);
                    addChild(node, $3);
                    $$ = node;
                }
                | andExpression                     { $$ = $1; }
                ;
andExpression: andExpression AND unaryRelExpression {
                    Node* node = newNode(nodes::Operator, $2);
                    addChild(node, $1);
                    addChild(node, $3);
                    $$ = node;
             }
             | unaryRelExpression                   { $$ = $1; }
             ;
unaryRelExpression: NOT unaryRelExpression          {
                    Node* node = newNode(nodes::Operator, $1);
                    addChild(node, $2);
                    $$ = node;
                  }
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

unaryExpression: unaryop unaryExpression    { 
                    Node* node = newNode(nodes::Operator, $1);
                    addChild(node, $2);
                    $$ = node;
               }
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

call: ID '(' args ')'           {
        $$ = newNode(nodes::FunctionCall, $1);
        addChild($$, $3);
    } 
    ;

args: argList                   { $$ = $1; }
    |                           { $$ = NULL; }
    ;
argList: argList ',' expression { $$ = addSibling($1, $3); }
       | expression             { $$ = $1; }
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
            yyclearin;
            yyerror("Match error");
            $$ = errorNode($1);
        }
        ;

%%

int runWith(const char* str) {
    printf("Opening %s\n", str);
    if (str == NULL || !strcmp(str, "")) {
        printf("Couldn't open the input file: empty string\n");
        return EXIT_FAILURE;
    }
    FILE* f = fopen(str, "r");
    if (!f) {
        printf("Couldn't open the input file: %s\n", str);
        return EXIT_FAILURE;
    }
    return run(f);
}

int run(FILE* in) {
    yyin = in;
    while (!feof(in)) {
        yyparse();
    }
    return EXIT_SUCCESS;
}

Node* newNode(nodes::NodeType type, TokenData* token) {
    printf("creating node %s\n", toString(type)); 
    Node* node = new Node;
    node->nodeId = currNodeId++;
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
    printf("Number of errors: %d\n", numErrors);
    if (numErrors > 0) { 
        int i = 0;
        for (Node* err = errors[i]; err != NULL; err = errors[++i]) {
           printf("Error %d of %d at line %d: %s\n", i + 1, numErrors, err->lineno, err->tokenString); 
        }
    }
}

Node* addSibling(Node* existing, Node* addition) {
    char word[30];
    sprintf(word, "%s", stringifyNode(existing));
    printf("Add sibling call: %s -> %s\n", word, stringifyNode(addition));
    if (existing != NULL) {
        if (addition == NULL) return existing;
        if (existing->nodeId == addition->nodeId) {
            printf("Attempting to add node to self! %s, at line %d", stringifyNode(existing), existing->lineno);
            return existing;
        }

        Node* t = existing;
        while (t->sibling != NULL) {
            printf("Looking at node %s\n", stringifyNode(t));
            t = t->sibling;
        }
        addition->siblingIndex = t->siblingIndex + 1;
        t->sibling = addition;
        printf("Attached sibling %s->%s\n", t->tokenString, addition->tokenString);
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
        parent->numChildren++;
        if (child != NULL) {
            if (parent->nodeId == child->nodeId) {
                printf("Attempting to add node to itself as a child: %s line %d\n", stringifyNode(parent), parent->lineno);
                return parent;
            }
            char word[30];
            sprintf(word, "%s", stringifyNode(child));
            printf("Added child %s[%d] to %s[%d] at index %d\n", word, child->nodeId, stringifyNode(parent), parent->nodeId, idx);
        } else {
            printf("null child for parent %s\n", stringifyNode(parent));
        }
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

