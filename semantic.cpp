#include "semantic.h"
#include "printtree.h"
#include "c-.h"
#include "scanType.h"
#include "c-.tab.h"
#include <string.h>
#include <stdio.h>

extern int numErrors;
extern int numWarnings;

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
            if (!typesMatch("bool", left, NULL)) {
                printf("ERROR(%d): '%s' requires operands of type %s but lhs is of type %s.\n", parent->lineno, parent->tokenString, "bool", left->returnType);   
                numErrors++;
            } 
            if (!typesMatch("bool", right, NULL)) {
                printf("ERROR(%d): '%s' requires operands of type %s but rhs is of type %s.\n", parent->lineno, parent->tokenString, "bool", right->returnType);   
                numErrors++;
            }
            if (left->isArray || right->isArray) {
                printf("ERROR(%d): The operation '%s' does not work with arrays.\n", parent->lineno, parent->tokenString);
                numErrors++;
            }
            return "bool";
        }
        break;
    case NOT: {
            if (!typesMatch("bool", left, NULL)) {
                printf("ERROR(%d): Unary 'not' requires an operand of type bool but was given type %s.\n", parent->lineno, left->returnType);
                numErrors++;
            }
            if (left->isArray) {
                printf("ERROR(%d): The operation '%s' does not work with arrays.\n", parent->lineno, parent->tokenString);
                numErrors++;
            }
            return "bool";
        }
        break;
    // == !=    requires same types and nonvoid
    case EQ:
    case NOTEQ: {
            bool flag = false;
            if (!strcmp("void", left->returnType)) {
                printf("ERROR(%d): '%s' requires operands of NONVOID but lhs is of type void.\n", parent->lineno, parent->tokenString);
                numErrors++;
                flag = true;
            }
            if (!strcmp("void", right->returnType)) {
                printf("ERROR(%d): '%s' requires operands of NONVOID but rhs is of type void.\n", parent->lineno, parent->tokenString);
                numErrors++;
                flag = true;
            }
            if (!flag && strcmp(left->returnType, right->returnType)) {
                printf("ERROR(%d): '%s' requires operands of the same type but lhs is type %s and rhs is type %s.\n", parent->lineno, parent->tokenString, left->returnType, right->returnType);
                numErrors++;
            }
            if (!left->isArray != !right->isArray) {
                printf("ERROR(%d): '%s' requires that either both or neither operands be arrays.\n", parent->lineno, parent->tokenString);
                numErrors++;
            }
            return "bool";
        }
        break;
    // <= >= < >    types int or char, must both be same type
    case LESSEQ:
    case GRTEQ:
    case LESS:
    case GRTR: {
        bool flag = false;
        if (!typesMatch("char", left, NULL) && !typesMatch("int", left, NULL)) {
            printf("ERROR(%d): '%s' requires operands of type char or type int but lhs is of type %s.\n", parent->lineno, parent->tokenString, left->returnType);
            numErrors++;
            flag = true;
        }
        if (!typesMatch("char", right, NULL) && !typesMatch("int", right, NULL)) {
            printf("ERROR(%d): '%s' requires operands of type char or type int but rhs is of type %s.\n", parent->lineno, parent->tokenString, right->returnType);
            numErrors++;
            flag = true;
        }
        if (!flag && !typesMatch(left, right)) {
            printf("ERROR(%d): '%s' requires operands of the same type but lhs is type %s and rhs is type %s.\n", parent->lineno, parent->tokenString, left->returnType, right->returnType);
            numErrors++;
        }
        if (left->isArray || right->isArray) {
            printf("ERROR(%d): The operation '%s' does not work with arrays.\n", parent->lineno, parent->tokenString);
            numErrors++;
        }
        return "bool";
        }
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
            if (left->isArray || right->isArray) {
                printf("ERROR(%d): The operation '%s' does not work with arrays.\n", parent->lineno, parent->tokenString);
                numErrors++;
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
            if (right->tokenData->tokenClass == ID) {
                printf("ERROR(%d): Array index is the unindexed array '%s'.\n", right->lineno, right->tokenString);
            } else {
                printf("ERROR(%d): Array index is an unindexed array.\n", right->lineno);
            }
            numErrors++;
        }

        parent->isArray = false;
        return left->returnType;
        break;
    // ?: unary requires non array, int
    case QUEOP: {
            if (!typesMatch("int", left, NULL)) {
                printf("ERROR(%d): Unary '%s' requires an operand of type %s but was given type %s.\n", parent->lineno, parent->tokenString, "int", left->returnType);
                numErrors++;
            }
            if (left->isArray) {
                printf("ERROR(%d): The operation '?' does not work with arrays.\n", parent->lineno);
                numErrors++;
            }

            return "int";
        }
        break;

    case INC:
    case DEC:
    // . - + / += -= *= /= %
    case SUBOP: {
            if (right == NULL) {
                if (!typesMatch("int", left, NULL)) {
                    printf("ERROR(%d): Unary '%s' requires an operand of type int but was given type %s.\n", parent->lineno, parent->tokenString, left->returnType);
                    numErrors++;
                }
                if (left->isArray) {
                    printf("ERROR(%d): The operation '%s' does not work with arrays.\n", parent->lineno, parent->tokenString);
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

            if (right != NULL) {
                parent->isConstant = left->isConstant && right->isConstant;
            } else {
                parent->isConstant = left->isConstant;
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

Node* activeFunction = NULL;
int whileDepth = 0;
bool hasReturn = false;

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
            activeFunction = node;
            typeNode(node->children[0]);

            Node* body = node->children[1];
            if (body != NULL && body->nodeType == nodes::Compound) {
                body->changeScope = false;
            }

            typeNode(body);

            if (!hasReturn && strcmp("void", node->returnType) != 0) {
                printf("WARNING(%d): Expecting to return type %s but function '%s' has no return statement.\n", node->lineno, node->returnType, node->tokenString);
                numWarnings++;
            }

            activeFunction = NULL;
            hasReturn = false;
            symbolTable.leave();
            break;
        }
    case nodes::IfStatement: {
            typeNode(node->children[0]);
            if (!typesMatch("bool", node->children[0], NULL)) {
                printf("ERROR(%d): Expecting Boolean test condition in if statement but got type %s.\n", node->lineno, node->children[0]->returnType);
                numErrors++;
            }
            if (node->children[0]->isArray) {
                printf("ERROR(%d): Cannot use array as test condition in if statement.\n", node->lineno);
                numErrors++;
            }
            typeNode(node->children[1]);
            typeNode(node->children[2]);

            break;
        }
    case nodes::WhileStatement: {
            whileDepth++;

            typeNode(node->children[0]);
            if (!typesMatch("bool", node->children[0], NULL)) {
                printf("ERROR(%d): Expecting Boolean test condition in while statement but got type %s.\n", node->lineno, node->children[0]->returnType);
                numErrors++;
            }
            if (node->children[0]->isArray) {
                printf("ERROR(%d): Cannot use array as test condition in while statement.\n", node->lineno);
                numErrors++;
            }
            typeNode(node->children[1]);
            
            whileDepth--;
            break;
        }
    case nodes::Break: {
            if (whileDepth == 0) {
                printf("ERROR(%d): Cannot have a break statement outside of loop.\n", node->lineno);
                numErrors++;
            }
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
            if (!typesMatch(node, node->children[0])) {
                printf("ERROR(%d): Variable '%s' is of type %s but is being initialized with an expression of type %s.\n", node->lineno, node->tokenString, node->returnType, node->children[0]->returnType);
                numErrors++;
            }
            if (node->children[0] != NULL && !node->children[0]->isConstant) {
                printf("ERROR(%d): Initializer for variable '%s' is not a constant expression.\n", node->lineno, node->tokenString);
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
            } else  if (!typesMatch(left, rght)) {
                node->returnType = left->returnType;
                printf("ERROR(%d): '=' requires operands of the same type but lhs is type %s and rhs is type %s.\n", node->lineno, left->returnType, rght->returnType);
                numErrors++;
            }

            node->returnType = left->returnType;
            node->isArray = left->isArray;

            if (!left->isArray != !rght->isArray) {
                printf("ERROR(%d): '%s' requires that either both or neither operands be arrays.\n", node->lineno, node->tokenString);
                numErrors++;
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

            if (right != NULL) {
                node->isConstant = left->isConstant && right->isConstant;
            } else {
                node->isConstant = left->isConstant;
            }
            
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
            printf("ERROR(%d): Function '%s' is not defined.\n", node->lineno, node->tokenString);
            node->returnType = strdup("unknown");
            numErrors++;
        } else if (data->nodeType != nodes::Function) {
            printf("ERROR(%d): '%s' is a simple variable and cannot be called.\n", node->lineno, node->tokenString);
            node->returnType = data->returnType;
            numErrors++;
        } else {
            cloneNode(data, node);
        }
        // Don't need to loop through all parameters, just start at first
        //cause they're siblings so would be handled by normal flow

        // Do type & length checks on call args vs function params
        if (data != NULL && data->nodeType == nodes::Function) {
            bool lengthMismatch = false;
            int funcParamNum = 0;
            int callArgNum = 0;

            Node *fArg = data->children[0], *cArg = node->children[0]; 
            while (fArg != NULL || cArg != NULL) {

                if (fArg != NULL) funcParamNum++;
                if (cArg != NULL) callArgNum++;

                if (!lengthMismatch && (fArg == NULL || cArg == NULL)) {
                    lengthMismatch = true;
                    printf("ERROR(%d): Too %s parameters passed for function '%s' defined on line %d.\n", node->lineno, callArgNum > funcParamNum ? "many" : "few", data->tokenString, data->lineno);
                    numErrors++;
                }

                if (cArg != NULL) {
                    Node *tmp = cArg->sibling;
                    cArg->sibling = NULL;
                    typeNode(cArg);
                    cArg->sibling = tmp;
                }

                if (!lengthMismatch) {
                    if (!typesMatch(fArg, cArg)) {
                        printf("ERROR(%d): Expecting type %s in parameter %d of call to '%s' defined on line %d but got type %s.\n", node->lineno, fArg->returnType, callArgNum, node->tokenString, data->lineno, cArg->returnType);
                        numErrors++;
                    }
                    if (fArg->isArray && !cArg->isArray) {
                        printf("ERROR(%d): Expecting array in parameter %d of call to '%s' defined on line %d.\n", node->lineno, funcParamNum, data->tokenString, data->lineno);
                        numErrors++;
                    } else if (cArg->isArray && !fArg->isArray) {
                        printf("ERROR(%d): Not expecting array in parameter %d of call to '%s' defined on line %d.\n", cArg->lineno, callArgNum, data->tokenString, data->lineno);
                        numErrors++;
                    }
                }

                fArg = fArg != NULL ? fArg->sibling : NULL;
                cArg = cArg != NULL ? cArg->sibling : NULL;
            }
            if (cArg != NULL)
                typeNode(cArg);

//             if (lengthMismatch) {
//                 printf("ERROR(%d): Too %s parameters passed for function '%s' defined on line %d.\n", node->lineno, callArgNum > funcParamNum ? "many" : "few", data->tokenString, data->lineno);
//                 numErrors++;
//             }
        } else {
            typeNode(node->children[0]);
        }
        break;
    }
    case nodes::Return:
    case nodes::ReturnStatement: {
            Node* child = node->children[0];
            typeNode(child);
            if (child != NULL) {
                if (strcmp(activeFunction->returnType, "void") == 0) {
                    printf("ERROR(%d): Function '%s' at line %d is expecting no return value, but return has return value.\n", node->lineno, activeFunction->tokenString, activeFunction->lineno);
                    numErrors++;
                    node->returnType = strdup("void");
                } else if (!typesMatch(activeFunction, child)) {
                    printf("ERROR(%d): Function '%s' at line %d is expecting to return type %s but instead returns type %s.\n", node->lineno, activeFunction->tokenString, activeFunction->lineno, activeFunction->returnType, child->returnType); 
                    numErrors++;
                    // node->returnType = activeFunction->returnType;
                    //node->returnType = strdup("void");
                } else {
                    node->returnType = child->returnType;
                }

                if (child->isArray) {
                    printf("ERROR(%d): Cannot return an array.\n", node->lineno);
                    numErrors++;
                    node->returnType = strdup("void");
                    //break;
                }
                // node->returnType = strdup("void");
                // node->returnType = child->returnType;
            } else  {
                if (strcmp(activeFunction->returnType, "void") != 0) {
                    printf("ERROR(%d): Function '%s' at line %d is expecting to return type %s but return has no return value.\n", node->lineno, activeFunction->tokenString, activeFunction->lineno, activeFunction->returnType);
                    numErrors++;
                }
                node->returnType = strdup("void");
            }
            hasReturn = true;
            node->returnType = strdup("void");
        }
    default:
        break;
    }
    typeNode(node->sibling);
}

void analyzeAST(Node* root) {
    numWarnings = 0;

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

