%{

#include <string.h>
#include <stdio.h>
#include "c-.h"
#include "symbolTable.h"
#include "scanType.h"
#include "printtree.h"
#include "yyerror.h"

#define YYERROR_VERBOSE

using namespace std;

extern "C" int yylex();
extern "C" int yyparse();

const char* prefix();

Node* newNode(nodes::NodeType, TokenData*);
Node* errorNode(TokenData*);
Node* addSibling(Node*, Node*);
Node* addChild(Node*, Node*);
Node* addChild(Node*, Node*, int);

extern "C" FILE *yyin;

void log(const char *msg) {
    printf("Line %d: %s\n", lineno, msg);
}

Node* root;

int currNodeId = 0;

SymbolTable symbolTable;

Node* injectIORoutines(Node* root);

%}

%debug

%token <tokenData> TOK

%token <tokenData> BOOLCONST
%token <tokenData> ID
%token <tokenData> CHARCONST
%token <tokenData> NUMCONST

%token <tokenData> LESSEQ
%token <tokenData> NOTEQ
%token <tokenData> GRTEQ
%token <tokenData> EQ
%token <tokenData> LESS
%token <tokenData> GRTR

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
%token <tokenData> RECTYPE

%type <nodePtr> declarationList declaration varDeclaration varDeclList scopedVarDeclarations varDeclInitialize varDeclId funDeclaration recDeclaration returnStmt breakStmt statement matched unmatched otherstatements compoundStmt localDeclarations statementList expressionStmt expression simpleExpression andExpression unaryRelExpression relExpression sumExpression term unaryExpression factor params paramList paramTypeList paramIdList paramId constant mutable immutable call args argList

%type <tokenData> typeSpecifier scopedTypeSpecifier returnTypeSpecifier relop

%union {
    TokenData *tokenData;
    Node *nodePtr;
}

%%

program: declarationList        { addSibling(root, $1); } 
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
           ;

recDeclaration: RECORD ID LBRACE localDeclarations RBRACE   {
                    Node* node = newNode(nodes::Record, $1);
                    node->tokenString = strdup($2->tokenString);
                    addChild(node, $4);

                    if (!symbolTable.insert(strdup($2->tokenString), node)) {
                        printf("Insertion of %s failed (it probably already exists).", node->tokenString);
                        $$ = errorNode($2);
                    } else {
                        $$ = node;
                    }
              }
              ;

scopedVarDeclarations: scopedTypeSpecifier varDeclList SEMI  {
                        // For declarations in statements, loop through siblings and attach type and static info
                        for (Node* decl = $2; decl != NULL; decl = decl->sibling) {
                            decl->returnType = $1->tokenString;
                            decl->isStatic = $1->isStatic;
                        }
                        $$ = $2;
                     }
                     ;

varDeclaration: typeSpecifier varDeclList SEMI  {
                Node* n = $2;
                for (Node *s = n; s != NULL; s = s->sibling) {
                    s->nodeType = nodes::Variable;
                    s->returnType = $1->tokenString;
                }
                $$ = n;
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
            Node* node = newNode(nodes::Variable, $1);
            node->arraySize = atoi($3->tokenString);
            node->isArray = true;
            $$ = node;
         } 
         ;

scopedTypeSpecifier: STATIC typeSpecifier   { $2->isStatic = true;  $$ = $2; }
                   | typeSpecifier          { $1->isStatic = false; $$ = $1; }
                   ;

typeSpecifier: returnTypeSpecifier
             | RECTYPE                      {
                $$->tokenString = strdup("record");
                $$->recordType = strdup($$->tokenString);
                $$->isRecord = true;
                $$ = $1;
             }

returnTypeSpecifier: INT
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
                    s->returnType = $1->tokenString;
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
         | unmatched    { $$ = $1; }
         ;

matched: IF '(' simpleExpression ')' matched ELSE matched       {
            Node* node = newNode(nodes::IfStatement, $1);
            node->returnType = strdup("void");
            addChild(node, $3, 0);
            addChild(node, $5, 1);
            addChild(node, $7, 2);
            $$ = node;
       }
       | IF error ')' matched ELSE matched {
            Node* node = newNode(nodes::IfStatement, $1);
            node->returnType = strdup("void");
            addChild(node, $4, 1);
            addChild(node, $6, 2);
            $$ = node;
       }
       | WHILE '(' simpleExpression ')' matched {
            Node* node = newNode(nodes::WhileStatement, $1);
            node->returnType = strdup("void");
            addChild(node, $3, 0);
            addChild(node, $5, 1);
            $$ = node;
       }
       | otherstatements    { $$ = $1; }
       ;

unmatched: IF '(' simpleExpression ')' matched                  {
            Node* node = newNode(nodes::IfStatement, $1);
            node->returnType = strdup("void");
            addChild(node, $3, 0);
            addChild(node, $5, 1);
            $$ = node;
         }
         | IF '(' simpleExpression ')' unmatched                {
            Node* node = newNode(nodes::IfStatement, $1);
            node->returnType = strdup("void");
            addChild(node, $3, 0);
            addChild(node, $5, 1);
            $$ = node;
         }
         | IF '(' simpleExpression ')' matched ELSE unmatched   { 
            Node* node = newNode(nodes::IfStatement, $1);
            node->returnType = strdup("void");
            addChild(node, $3, 0);
            addChild(node, $5, 1);
            addChild(node, $7, 2);
            $$ = node;
         }
         | IF error                 { 
            Node* node = newNode(nodes::IfStatement, $1);
            node->returnType = strdup("void");
            $$ = node;
         }
         | IF error ')' statement {
            Node* node = newNode(nodes::IfStatement, $1);
            node->returnType = strdup("void");
            addChild(node, $4, 1);
            $$ = node;

            yyerrok;
         }

         | WHILE '(' simpleExpression ')' unmatched {
            Node* node = newNode(nodes::WhileStatement, $1);
            node->returnType = strdup("void");
            addChild(node, $3, 0);
            addChild(node, $5, 1);
            $$ = node;
         }
         ;

otherstatements: expressionStmt     { $$ = $1; }
               | compoundStmt       { $$ = $1; }
               | returnStmt         { $$ = $1; }
               | breakStmt          { $$ = $1; }
               ;

compoundStmt: LBRACE localDeclarations statementList  RBRACE  {
                Node* node = newNode(nodes::Compound, $1);
                node->returnType = strdup("void");
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

expressionStmt: expression SEMI  { $$ = $1;   yyerrok; } 
              | SEMI             { $$ = NULL; yyerrok; }
              ;

returnStmt: RETURN SEMI                  {
                $$ = newNode(nodes::Return, $1);
                $$->returnType = strdup("void");
          }
          | RETURN expression SEMI       {
                Node* node = newNode(nodes::ReturnStatement, $1);
                addChild(node, $2);
                $$ = node;
          }
          ;
breakStmt: BREAK SEMI                    { 
            $$ = newNode(nodes::Break, $1); 
            $$->returnType = strdup("void");
         } 
         ;

expression: mutable ASS expression      {
            Node* node = newNode(nodes::Assignment, $2);
            addChild(node, $1);
            addChild(node, $3);
            $$ = node;
          }
          | error ASS error             {
            $$ = newNode(nodes::Assignment, $2);
          }
          | mutable ADDASS expression   {
            Node* node = newNode(nodes::AddAssignment, $2);
            addChild(node, $1);
            addChild(node, $3);
            $$ = node;
          } 
          | mutable SUBASS expression   {
            Node* node = newNode(nodes::SubAssignment, $2);
            addChild(node, $1);
            addChild(node, $3);
            $$ = node;
          }  
          | mutable MULASS expression   { 
            Node* node = newNode(nodes::MulAssignment, $2);
            addChild(node, $1);
            addChild(node, $3);
            $$ = node;
          } 
          | mutable DIVASS expression   {
            Node* node = newNode(nodes::DivAssignment, $2);
            addChild(node, $1);
            addChild(node, $3);
            $$ = node;
          }
          | mutable INC                 {
            Node* node = newNode(nodes::IncrementAssignment, $2);
            addChild(node, $1);
            $$ = node;
          } 
          | mutable DEC                 { 
            Node* node = newNode(nodes::DecrementAssignment, $2);
            addChild(node, $1);
            $$ = node;
          } 
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
relExpression: sumExpression relop sumExpression    { 
                Node* node = newNode(nodes::Operator, $2);
                addChild(node, $1);
                addChild(node, $3);
                $$ = node;
             }
             | sumExpression                        { $$ = $1; }
             ;

relop: EQ
     | NOTEQ
     | GRTEQ
     | LESSEQ
     | LESS
     | GRTR
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
      ;
mutable: ID                     { 
            $$ = newNode(nodes::Identifier, $1);
       }
       | mutable LBRACKET expression RBRACKET  {
            Node* t = newNode(nodes::Operator, $2);
            addChild(t, $1);
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
            $$->isConstant = true;
            $$->returnType = strdup("int");
        }
        | CHARCONST {
            $$ = newNode(nodes::Constant, $1);
            char c[2];
            sprintf(c, "'%c'", $1->cval);
            $$->tokenString = strdup(c);
            $$->isConstant = true;
            $$->returnType = strdup("char");
        }
        | BOOLCONST {
            $$ = newNode(nodes::Constant, $1);
            $$->isConstant = true;
            $$->returnType = strdup("bool");
        }
        ;

%%

int runWith(const char* str) {
    if (str == NULL || !strcmp(str, "")) {
        printf("ERROR(ARGLIST): source file \"%s\" could not be opened.\n", str);
        exit(EXIT_FAILURE);
    }
    FILE* f = fopen(str, "r");
    if (!f) {
        printf("ERROR(ARGLIST): source file \"%s\" could not be opened.\n", str);
        exit(EXIT_FAILURE);
    }
    return run(f);
}

int run(FILE* in) {
    root = injectIORoutines(NULL);
    initErrorProcessing();

    yyin = in;
    while (!feof(in)) {
        yyparse();
    }
    return EXIT_SUCCESS;
}

Node* newNode(nodes::NodeType type, TokenData* token) {
    Node* node = new Node;
    node->nodeId = currNodeId++;
    node->nodeType = type;
    if (token != NULL) {
        node->tokenString = strdup(token->tokenString);
        node->lineno = token->lineno;
    }
    node->type = toString(type);

    node->sibling = NULL;
    node->siblingIndex = -1;
    
    for (int i = 0; i < MAX_CHILDREN; i++)
        node->children[i] = NULL;

    // semantic helpers
    node->changeScope = true;
    node->isConstant = false;
    node->tokenData = token;

    return node;
}

Node* errorNode(TokenData* data) {
    Node* err = newNode(nodes::Error, data);
    return err;
}

Node* addSibling(Node* existing, Node* addition) {
    if (existing != NULL) {
        if (addition == NULL) return existing;
        if (existing->nodeId == addition->nodeId) {
            printf("Attempting to add node to self! %s, at line %d", stringifyNode(existing), existing->lineno);
            return existing;
        }

        Node* t = existing;
        while (t->sibling != NULL) {
            t = t->sibling;
        }
        addition->siblingIndex = t->siblingIndex + 1;
        t->sibling = addition;

        // If this node being added already has siblings, we need to update their indices
        int newSibIndex = addition->siblingIndex;
        for (Node* sib = addition->sibling; sib != NULL; sib = sib->sibling) {
            sib->siblingIndex = ++newSibIndex;            
        }
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
    if (parent == NULL) {
        printf("Attempting to add child %s to null parent!", stringifyNode(child));
        return NULL;
    }
    if (idx < parent->numChildren) {
        printf("Parent is %s\n", stringifyNode(parent));
        printf("Index is below current child count for [%s]->[%s], index %d, but count is %d!\n", parent->type, child->type, idx, parent->numChildren);
    } else if (idx >= MAX_CHILDREN) {
        printf("Trying to add child [%s] to [%s] but %d exceeds max children %d!\n", parent->type, child->type, idx, MAX_CHILDREN);
    } else {
        parent->children[idx] = child;
        if (idx > parent->numChildren) {
            parent->numChildren = idx + 1;
        } else {
            parent->numChildren++;
        }
        if (child != NULL) {
            if (parent->nodeId == child->nodeId) {
                printf("Attempting to add node to itself as a child: %s line %d\n", stringifyNode(parent), parent->lineno);
                return parent;
            }
        } else {
            ;
        }
    }

    return parent;
}

const char* prefix() {
    static char message[64];
    sprintf(message, "Line %d Token:", lineno);
    return message;
}

Node* funcWithParamOf(const char *name, const char* ret, const char* param) {
    Node* function = newNode(nodes::Function, NULL);
    function->tokenString = strdup(name);
    function->returnType = strdup(ret);
    function->lineno = -1;
    if (param != NULL) {
        Node* parameter = newNode(nodes::Parameter, NULL);
        parameter->tokenString = strdup("*dummy*");
        parameter->returnType = strdup(param);
        parameter->lineno = -1;
        addChild(function, parameter);
    }

    return function;
}

Node* injectIORoutines(Node* after) {
    Node *first = funcWithParamOf("input", "int", NULL);
    addSibling(first, funcWithParamOf("output", "void", "int"));
    addSibling(first, funcWithParamOf("inputb", "bool", NULL));
    addSibling(first, funcWithParamOf("outputb", "void", "bool"));
    addSibling(first, funcWithParamOf("inputc", "char", NULL));
    addSibling(first, funcWithParamOf("outputc", "void", "void"));
    addSibling(first, funcWithParamOf("outnl", "void", NULL));

    for (Node *n = first; n != NULL; n = n->sibling) {
        symbolTable.insert(n->tokenString, n);
    }

    if (after != NULL) {
        Node *n;
        for (n = after; n->sibling != NULL; n = n->sibling) ;
        n->sibling = first;
    }        

    return first;
}
