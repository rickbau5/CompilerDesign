#include "semantic.h"
#include "printtree.h"
#include "c-.h"
#include "scanType.h"
#include "c-.tab.h"
#include <stdio.h>

extern int numErrors;

void cloneNode(Node* src, Node* dest) {
    dest->returnType = src->returnType;
    dest->isStatic = src->isStatic;
    dest->isArray = src->isArray;
    dest->arraySize= src->arraySize;
}

bool typesMatch(Node* a, Node* b) {
    if (b == NULL) 
        return true;
    if (strcmp(a->returnType, "unknown") && strcmp(b->returnType, "unknown")) {
        return !strcmp(a->returnType, b->returnType);
    } else {
        return true;
    }
}

bool typesMatch(const char* typ, Node* a, Node* b) {
    if (typesMatch(a, b)) {
        return !strcmp(typ, a->returnType) || !strcmp("unknown", a->returnType);
    } else {
        return false;
    }
}

const char* computeType(Node* parent, Node* left, Node* right) {
    if (parent->nodeType == nodes::Operator) {
        switch (parent->tokenData->tokenClass) {
        case AND:
        case OR:
            if (typesMatch("bool", left, right)) {
                return "bool";
            } else {
                if (!typesMatch("bool", left, NULL)) {
                    printf("ERROR(%d): '%s' requires operands of %s but lhs is of %s.\n", parent->lineno, parent->tokenString, "bool", left->returnType);   
                } else if (!typesMatch("bool", left, right)) {
                    printf("ERROR(%d): '%s' requires operands of %s but rhs is of %s.\n", parent->lineno, parent->tokenString, "bool", right->returnType);   
                }
            }   
            break;
        case EQ:
        case NOTEQ:
            if (typesMatch("bool", left, right) || typesMatch("char", left, right) || typesMatch("int", left, right)) {
                return "bool";
            }
            break;
        case LESSEQ:
        case GRTEQ:
        case LESS:
        case GRTR:
            break;

        case MULOP:
            if (right == NULL) {
                bool valid = left->isArray && (
                        typesMatch("bool", left, NULL) || typesMatch("char", left, NULL) ||
                        typesMatch("int", left, NULL)
                        );
                if (valid)
                    return "int";
                else
                    return "unknown";
            } else {
                printf("Found binary '*'.\n");
            }
        default:
            if (typesMatch("int", left, right)) {
                return "int";
            }
            ;
        }
    }

    return "unknown";
}

void typeNode(Node* node) {
    if (node == NULL)
        return;

    switch(node->nodeType) {
    case nodes::Function: {
            printf("Entering \"%s\"\n", node->tokenString);
            symbolTable.insert(node->tokenString, node);
            symbolTable.enter(node->tokenString);
            for (Node *c = node->children[0]; c != NULL; c = c->sibling) {
                symbolTable.insert(c->tokenString, c);
            }

            Node* body = node->children[1];
            if (body != NULL && body->nodeType == nodes::Compound) {
                body->changeScope = false;
            }

            typeNode(body);

            break;
        }
    case nodes::Compound: {
            if (node->changeScope) {
                puts("Entering \"cmpd\"");
                symbolTable.enter("cmpd");
            }
            typeNode(node->children[0]);
            typeNode(node->children[1]);
            break;
        }
    case nodes::Variable: {
            if (!symbolTable.insert(node->tokenString, node)) {
                printf("ERROR(%d): Variable %s was already declared in this scope.\n", node->lineno, node->tokenString);
                numErrors++;
            }

            break;
        }
    case nodes::Assignment: {
            Node* left = node->children[0];
            Node* rght = node->children[1];
            typeNode(left);
            typeNode(rght);

            //if (strcmp(left->returnType, rght->returnType) && (strcmp(left->returnType, "unknown") && strcmp(rght->returnType, "unknown"))) {
            if (!typesMatch(left, rght)) {
                node->returnType = left->returnType;
                printf("ERROR(%d): '=' requires operands of the same type but lhs is type %s and rhs is type %s.\n", node->lineno, left->returnType, rght->returnType);
                numErrors++;
            } else {
                node->returnType = left->returnType;
            }

            break;
        }
    case nodes::Operator: {
            Node* left = node->children[0];
            Node* right = node->children[1];
            typeNode(left);
            typeNode(right);
            const char* val = computeType(node, left, right);
            node->returnType = strdup(val);
            printf("L(%d): Set type of '%s' to '%s'\n", node->lineno, node->tokenString, node->returnType);
            
            break;
        }
    case nodes::Identifier: {
            Node* data = (Node *)symbolTable.lookup(node->tokenString);
            if (data != NULL) {
                if (data->nodeType == nodes::Function) {
                    printf("ERROR(%d): Cannot use function '%s' as a variable.\n", node->lineno, node->tokenString);
                    node->returnType = strdup("unknown");
                    numErrors++;
                } else {
                    cloneNode(data, node);
                }
            } else {
                printf("ERROR(%d): Symbol '%s' is not defined.\n", node->lineno, node->tokenString);
                node->returnType = strdup("unknown");
                numErrors++;
            }
            break;
        }
    case nodes::ReturnStatement: {
            Node* child = node->children[0];
            typeNode(child);
            if (child != NULL) {
                if (child->isArray) {
                    printf("ERROR(%d): Cannot return an array.\n", node->lineno);
                    break;
                }
            }
        }
    default:
        break;
    }
    typeNode(node->sibling);
}

void typeTree(Node* root) {

    typeNode(root);
    bool mainFound = false;
    for (Node* n = root; n != NULL; n = n->sibling) {
        if (!strcmp(n->tokenString, "main")) {
            mainFound = true;
            break;
        }
    }
    if (!mainFound) {
        printf("ERROR(LINKER): Procedure main is not defined.\n");
        numErrors++;
    }
}

