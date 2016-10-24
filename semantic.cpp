#include "semantic.h"
#include "printtree.h"
#include "c-.h"
#include "scanType.h"
#include "c-.tab.h"
#include <string.h>
#include <stdio.h>

extern int numErrors;

// Copy info from the source node to the destination node
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

// Check if types:
//      1) match each other
//      2) match the specified type
// Note: "unknown" matches anything
bool typesMatch(const char* typ, Node* a, Node* b) {
    if (a != NULL && typesMatch(a, b)) {
        if (a->returnType == NULL) {
            return false;
        }
        return !strcmp(typ, a->returnType) || !strcmp("unknown", a->returnType);
    } else {
        return false;
    }
}

const char* computeType(Node* parent, Node* left, Node* right) {
    switch (parent->tokenData->tokenClass) { 
    // and or   Requires both to be bool
    case AND:
    case OR: {
            bool flag = true;
            if (!typesMatch("bool", left, NULL)) {
                printf("ERROR(%d): '%s' requires operands of type %s but lhs is of type %s.\n", parent->lineno, parent->tokenString, "bool", left->returnType);   
                numErrors++;
                flag = false;
            } 
            if (!typesMatch("bool", right, NULL)) {
                printf("ERROR(%d): '%s' requires operands of type %s but rhs is of type %s.\n", parent->lineno, parent->tokenString, "bool", right->returnType);   
                numErrors++;
                flag = false;
            }
            return "bool";
        }
        break;
    case NOT: {
            if (!typesMatch("bool", left, NULL)) {
                printf("ERROR(%d): Unary 'not' requires an operand of type type bool but was given type %s.\n", parent->lineno, left->returnType);
                numErrors++;
            } else {
                return "bool";
            }
        }
        break;
    // == !=    requires same types and nonvoid
    case EQ:
    case NOTEQ: {
            if (!strcmp("void", left->returnType)) {
                printf("ERROR(%d): '%s' requires operands of NONVOID but lhs is of type void.\n", parent->lineno, parent->tokenString);
                numErrors++;
            }
            if (!strcmp("void", right->returnType)) {
                printf("ERROR(%d): '%s' requires operands of NONVOID but rhs is of type void.\n", parent->lineno, parent->tokenString);
                numErrors++;
            }
            if (strcmp(left->returnType, right->returnType)) {
                printf("ERROR(%d): '%s' requires operands of the same type but lhs is type %s and rhs is type %s.\n", parent->lineno, parent->tokenString, left->returnType, right->returnType);
                numErrors++;
            }
            return "bool";
        }
        break;
    // <= >= < >    types int or char, must both be same type
    case LESSEQ:
    case GRTEQ:
    case LESS:
    case GRTR:
        if (!left->isArray && !right->isArray) {
            bool flag = true;
            if (!typesMatch("char", left, NULL) && !typesMatch("int", left, NULL)) {
                printf("ERROR(%d): '%s' requires operands of type char or type int but lhs is of type %s.\n", parent->lineno, parent->tokenString, left->returnType);
                numErrors++;
                flag = false;
            }
            if (!typesMatch("char", right, NULL) && !typesMatch("int", right, NULL)) {
                printf("ERROR(%d): '%s' requires operands of type char or type int but rhs is of type %s.\n", parent->lineno, parent->tokenString, right->returnType);
                numErrors++;
                flag = false;
            }
            if (flag && !typesMatch(left, right)) {
                printf("ERROR(%d): '%s' requires operands of the same type but lhs is type %s and rhs is type %s.\n", parent->lineno, parent->tokenString, left->returnType, right->returnType);
                numErrors++;
            }
            return "bool";
        } else {
            printf("ERROR(%d): The operation '%s' does not work with arrays.\n", parent->lineno, parent->tokenString);
            numErrors++;
        }
        break;

    case MULOP:
        if (right == NULL) {
            bool valid = (left->isArray || !strcmp(left->returnType, "unknown")) && (
                    typesMatch("bool", left, NULL) || typesMatch("char", left, NULL) ||
                    typesMatch("int", left, NULL)
                    );
            if (!valid) {
                printf("ERROR(%d): The operation '%s' only works with arrays.\n", parent->lineno, parent->tokenString);
                numErrors++;
            }
            return "int";
        } else {
            bool flag = true;
            if (!typesMatch("int", left, NULL)) {
                printf("ERROR(%d): '%s' requires operands of type %s but lhs is of type %s.\n", parent->lineno, parent->tokenString, "int", left->returnType);
                numErrors++;
                flag = false;
            }
            if (!typesMatch("int", right, NULL)) {
                printf("ERROR(%d): '%s' requires operands of type %s but rhs is of type %s.\n", parent->lineno, parent->tokenString, "int", right->returnType);
                numErrors++;
                flag = false;
            }
            return "int";
        }
        break;
    case LBRACKET:
        if (!left->isArray) {
            if (left->tokenData->tokenClass == LBRACKET) {
                printf("ERROR(%d): Cannot index nonarray.\n", left->lineno);
            } else {
                printf("ERROR(%d): Cannot index nonarray '%s'.\n", left->lineno, left->tokenString);
            }
            numErrors++;
            if (!typesMatch("int", right, NULL)) {
                printf("ERROR(%d): Array '%s' should be indexed by type int but got type %s.\n", parent->lineno, left->tokenString, right->returnType);
                numErrors++;
            }
        } else if (!typesMatch("int", right, NULL)) {
            printf("ERROR(%d): Array '%s' should be indexed by type int but got type %s.\n", right->lineno, left->tokenString, right->returnType);
            numErrors++;
        } 

        if (right->isArray) {
            printf("ERROR(%d): Array index is the unindexed array '%s'.\n", right->lineno, right->tokenString);
            numErrors++;
        }

        return left->returnType;
        break;
    // ?: unary requires non array, int
    case QUEOP: {
            if (!typesMatch("int", left, NULL)) {
                printf("ERROR(%d): Unary '%s' requires an operand of type type %s but was given type %s.\n", parent->lineno, parent->tokenString, "int", left->returnType);
                numErrors++;
            }
            if (left->isArray) {
                printf("ERROR(%d): The operation '?' does not work with arrays.\n", parent->lineno);
                numErrors++;
            }

            return "int";
        }
        break;

    // . - + / += -= *= /= %
    case SUBOP: {
            if (right == NULL) {
                if (!typesMatch("int", left, NULL)) {
                    printf("ERROR(%d): Unary '-' requires an operand of type type int but was given type %s.\n", parent->lineno, left->returnType);
                    numErrors++;
                }
                return "int";
            }
            // else fall through cause it's a binary operator
        }
    case ACC:
    case ADDASS: 
    case SUBASS:
    case MULASS:
    case DIVASS:
    case ADDOP:
    case DIVOP:
    case MODOP: {
            // printf("L(%d): here\n", parent->lineno);
            // printf("CT: lhs: %s, rhs: %s\n", left->returnType, right->returnType);
            bool flag = true;
            if (right == NULL) {
                printf("L(%d): Null right\n", left->lineno);
                prettyPrintTree(parent);
            }
            if (!typesMatch("int", left, NULL)) {
                printf("ERROR(%d): '%s' requires operands of type %s but lhs is of type %s.\n", parent->lineno, parent->tokenString, "int", left->returnType);
                numErrors++;
                flag = false;
            }
            if (!typesMatch("int", right, NULL)) {
                printf("ERROR(%d): '%s' requires operands of type %s but rhs is of type %s.\n", parent->lineno, parent->tokenString, "int", right->returnType);
                numErrors++;
                flag = false;
            }
            // Check if array
            if (left->isArray || right->isArray) {
                printf("ERROR(%d): The operation '%s' does not work with arrays.\n", parent->lineno, parent->tokenString);
                numErrors++;
            }
            return "int";
        }
        break;
    default:
        if (typesMatch("int", left, right)) {
            return "int";
        }
    }

    return "unknown";
}

void typeNode(Node* node) {
    if (node == NULL)
        return;

    switch(node->nodeType) {
    case nodes::Function: {
            // Check if the function already exists
            if (!symbolTable.insert(node->tokenString, node)) {
                Node* existing = (Node*)symbolTable.lookup(node->tokenString);
                printf("ERROR(%d): Symbol '%s' is already defined at line %d.\n", node->lineno, node->tokenString, existing->lineno);
                numErrors++;
            }

            // Even if it already exists, let's analyze it
            symbolTable.enter(node->tokenString);
            typeNode(node->children[0]);

            Node* body = node->children[1];
            if (body != NULL && body->nodeType == nodes::Compound) {
                body->changeScope = false;
            }

            typeNode(body);

            symbolTable.leave();
            break;
        }
    case nodes::IfStatement: {
            typeNode(node->children[0]);
            typeNode(node->children[1]);
            typeNode(node->children[2]);

            break;
        }
    case nodes::WhileStatement: {
            typeNode(node->children[0]);
            typeNode(node->children[1]);

            break;
        }
    case nodes::Compound: {
            if (node->changeScope) {
                symbolTable.enter("cmpd");
            }
            typeNode(node->children[0]);
            typeNode(node->children[1]);

            if (node->changeScope) {
                symbolTable.leave();
            }
            break;
        }
    case nodes::Record: {
            // Do nothing with records for now
            printf("SYSTEM ERROR: Unknown declaration node kind: 0\n");
            break;
        }
    case nodes::Parameter:
    case nodes::Variable: {
            // Type child, which would be initialization for a variable
            typeNode(node->children[0]);
            if (!symbolTable.insert(node->tokenString, node)) {
                Node* existing = (Node*)symbolTable.lookup(node->tokenString);
                printf("ERROR(%d): Symbol '%s' is already defined at line %d.\n", node->lineno, node->tokenString, existing->lineno);
                numErrors++;
            }

            break;
        }
    case nodes::Assignment: {
            Node* left = node->children[0];
            Node* rght = node->children[1];
            typeNode(left);
            typeNode(rght);

            if (rght->returnType == NULL) {
                printf("Null right %s...\n", rght->tokenString);
                prettyPrintTree(node);
            } else if (!strcmp("void", rght->returnType)) {
                printf("ERROR(%d): '=' requires operands of NONVOID but rhs is of type void.\n", node->lineno);
                numErrors++;
                node->returnType = left->returnType;
            } else  if (!typesMatch(left, rght)) {
                node->returnType = left->returnType;
                printf("ERROR(%d): '=' requires operands of the same type but lhs is type %s and rhs is type %s.\n", node->lineno, left->returnType, rght->returnType);
                numErrors++;
            } else {
                node->returnType = left->returnType;
            }

            break;
        }
    case nodes::AddAssignment:
    case nodes::SubAssignment:
    case nodes::MulAssignment:
    case nodes::DivAssignment:
    case nodes::IncrementAssignment:
    case nodes::DecrementAssignment:
    case nodes::Operator: {
            Node* left = node->children[0];
            Node* right = node->children[1];
            typeNode(left);
            typeNode(right);
            const char* val = computeType(node, left, right);
            node->returnType = strdup(val);
            
            break;
        }
    case nodes::Identifier: {
            Node* data = (Node *)symbolTable.lookupAnywhere(node->tokenString);
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
    case nodes::FunctionCall: {
        Node* data = (Node*)symbolTable.lookup(node->tokenString);
        if (data == NULL) {
            printf("ERROR(%d): Symbol '%s' is not defined.\n", node->lineno, node->tokenString);
            node->returnType = strdup("unknown");
            numErrors++;
        } else if (data->nodeType != nodes::Function) {
            printf("ERROR(%d): '%s' is a simple variable and cannot be called.\n", node->lineno, node->tokenString);
            node->returnType = strdup("unknown");
            numErrors++;
        } else {
            cloneNode(data, node);
        }
        // Don't need to loop through all parameters, just start at first
        //cause they're siblings so would be handled by normal flow
        typeNode(node->children[0]);
        break;
    }
    case nodes::ReturnStatement: {
            Node* child = node->children[0];
            typeNode(child);
            if (child != NULL) {
                if (child->isArray) {
                    printf("ERROR(%d): Cannot return an array.\n", node->lineno);
                    numErrors++;
                    break;
                }
                node->returnType = strdup("void");
            }
        }
    default:
        break;
    }
    typeNode(node->sibling);
}

void analyzeAST(Node* root) {
    typeNode(root);

    // Search for main in global scopes
    bool mainFound = false;
    for (Node* n = root; n != NULL; n = n->sibling) {
        if (n->nodeType == nodes::Function && !strcmp(n->tokenString, "main")) {
            mainFound = true;
            break;
        }
    }
    if (!mainFound) {
        printf("ERROR(LINKER): Procedure main is not defined.\n");
        numErrors++;
    }
}

