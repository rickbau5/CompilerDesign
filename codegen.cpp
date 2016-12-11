#include "codegen.h"

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "emitcode.h"
#include "c-.h"
#include "c-.tab.h"

void doCodeGeneration(Node*);

int framePointer;
bool onRight;

void generateExpression(Node* expr) {
    if (expr == NULL) // Unary operators
        return;

    Node* left = expr->children[0];
    Node* right = expr->children[1];

    bool handled = false;
    switch (expr->nodeType) {
        case nodes::FunctionCall: {
                Node* mainFunc = (Node*)symbolTable.lookup(expr->tokenString);
                emitCommentRight("Begin call to", (char*) expr->tokenString);

                emitRM("ST", 1, framePointer, 1, "Store old fp in ghost frame");
                framePointer -= 2; // Advance framepointer
                for (Node* n = expr->children[0]; n != NULL; n = n->sibling) {
                    emitRM("LD", 3, n->loc, 1, "Load variable", (char*) n->tokenString);
                    emitRM("ST", 3, framePointer, 1, "Store parameter");
                }
                framePointer += 2;
                emitCommentRight("Jump to output");
                emitRM("LDA", 1, framePointer, 1, "Load address of new frame");
                emitRM("LDA", 3, 1, 7, "Return address in ac");
                emitRM("LDA", 7, -emitSkip(0) - mainFunc->loc - 2, 7, "CALL", (char*) expr->tokenString);
                emitRM("LDA", 3, 0, 2, "Save the result in ac");

                emitCommentRight("End call to", (char*) expr->tokenString);
                handled = true;
            }
            break;
        case nodes::Operator: {
                char opString[3];
                bool save = true;
                switch (expr->tokenData->tokenClass) {
                    case ADDOP:
                        sprintf(opString, "%s", "ADD");
                        break;
                    case MULOP:
                        sprintf(opString, "%s", "MUL");
                        break;
                    case DIVOP:
                        sprintf(opString, "%s", "DIV");
                        break;
                    case SUBOP:
                        sprintf(opString, "%s", "SUB");
                        break;

                    case LBRACKET:
                        goto exit;
                    default:
                        sprintf(opString, "%s", expr->tokenString);
                        save = false;
                        break;
                }

                generateExpression(left);
                if (save) {
                    emitRM("ST", 3, framePointer, 1, "Save left side");
                }
                generateExpression(right);
                emitRM("LD", 4, framePointer, 1, "Load left into ac1");
                handled = true;
                emitRO(opString, 3, 4, 3, "Op", (char*)expr->tokenString);
            }
            break;

        case nodes::Constant:
            emitRM("LDC", 3, expr->tokenData->ival, 6, "Load integer constant");
            handled = true;
            break;
        default:
            break;
    }
    exit: ;
    if (!handled) {
        switch (expr->tokenData->tokenClass) {
            case ASS: {
                    if (left->nodeType == nodes::Identifier) {
                        if (right->nodeType == nodes::Constant) {
                            emitRM("LDC", 3, right->intValue, 6, "Load integer constant");
                            emitRM("ST", 3, left->loc, 1, "Store variable", (char*) left->tokenString);
                        } else if (right->nodeType == nodes::Identifier) {
                            emitRM("LD", 3, right->loc, 1, "Load variable", (char*) right->tokenString);
                            emitRM("ST", 3, left->loc, 1, "Store variable", (char*) left->tokenString);
                        } else {
                            onRight = true;
                            generateExpression(right);
                            onRight = false;

                            if (right->tokenData->tokenClass == LBRACKET) {
                                emitRM("LD", 4, framePointer, 1, "Load left into ac1 ");
                                emitRO("SUB", 3, 4, 3, "compute location from index ");
                                emitRM("LD", 3, 0, 3, "Load array element");
                                emitRM("ST", 3, left->loc, 1, "Store variable", (char*) left->tokenString);
                            }
                        }
                    } else {
                        generateExpression(left);
                        generateExpression(right);

                        if (left->tokenData->tokenClass == LBRACKET) {
                            emitRM("LD", 4, -15, 1, "Restore index");
                            emitRM("LDA", 5, left->children[0]->loc, 1, "Load address of base of array", (char*) left->children[0]->tokenString);
                            emitRO("SUB", 5, 5, 4, "Compute offset of value");
                        }
                        emitRM("ST", 3, 0, 5, "Store variable", (char*)left->children[0]->tokenString);
                    }
                }
                break;
            case LBRACKET: {
                    if (onRight) {
                        emitRM("LDA", 3, left->loc, 1, "Load address of base of array");
                        emitRM("ST", 3, framePointer, 1, "Save left side");
                        --framePointer;
                    }
                    generateExpression(right);
                    if (!onRight)
                        emitRM("ST", 3, -15, 1, "Save index");
                    else 
                        framePointer++;
                     
                    break;
                }
            default:
                emitComment("Unimplemented expr", (char*) expr->tokenString);
                break;
        }
    }
}

void pimpIO(Node* node) {
    if (node->isIONode) {
        if (!strcmp(node->tokenString, "input")) {
            emitRO("IN", 2, 2, 2, "Grab int input");
        } else if (!strcmp(node->tokenString, "output")) {
            emitRO("OUT", 3, 3, 3, "Output integer");
        } else if (!strcmp(node->tokenString, "inputb")) {
            emitRO("INB", 2, 2, 2, "Grab bool input");
        } else if (!strcmp(node->tokenString, "outputb")) {
            emitRO("OUTB", 3, 3, 3, "Output bool");
        } else if (!strcmp(node->tokenString, "inputc")) {
            emitRO("INC", 2, 2, 2, "Grab char input");
        } else if (!strcmp(node->tokenString, "outputc")) {
            emitRO("OUTC", 3, 3, 3, "Output char");
        } else if (!strcmp(node->tokenString, "outnl")) {
            emitRO("OUTNL", 3, 3, 3, "Output a newline");
        }
    }
}

void doCodeGeneration(Node* node) {
    if (node == NULL)
        return;
    switch (node->nodeType) {
        case nodes::Function: { 
                framePointer = node->memSize;
                emitComment("** ** ** ** ** ** ** ** ** ** ** **");
                emitComment("FUNCTION", (char*) node->tokenString);
                emitRM("ST", 3, -1, 1, "Store return address");

                // Function Body
                node->loc = -emitSkip(0);
                doCodeGeneration(node->children[0]);
                doCodeGeneration(node->children[1]);
                pimpIO(node);

                if (!strcmp(node->returnType, "void") && strcmp(node->tokenString, "outnl")) {
                    emitRM("LDC", 2, 0, 6, "Set return to 0");
                }
                emitRM("LD", 3, -1, 1, "Load return address");
                emitRM("LD", 1, 0, 1, "Adjust fp");
                emitRM("LDA", 7, 0, 3, "Return");
                emitComment("END FUNCTION", (char*) node->tokenString);
                if (!strcmp("main", node->tokenString)) {
                    backPatchAJumpToHere(0, "Jump to init [backpatch]");
                }
                emitComment("");
            }
            break;
        case nodes::Compound: {
                int before = framePointer;
                emitComment("COMPOUND");
                for (Node* n = node->children[0]; n != NULL; n = n->sibling) {
                    if (n->isArray) {
                        emitRM("LDC", 3, n->arraySize, 6, "load size of array", (char*) n->tokenString);
                        emitRM("ST", 3, -4, 1, "save size of array", (char*) n->tokenString);
                    }
                }
                emitComment("Compound Body");
                doCodeGeneration(node->children[1]);
                framePointer = before;
                emitComment("END COMPOUND");
            }
            break;

        case nodes::Parameter: {
                emitRM("LD", 3, -2, 1, "Load parameter");
            }
            break;
        case nodes::FunctionCall:
        case nodes::Assignment:
            emitComment("EXPRESSION");
            generateExpression(node);
            
            break;
        default:
            emitComment("Unimplemented", (char*) node->tokenString);
            break;
    }
    doCodeGeneration(node->sibling);
}

void genInit(int endOfGlobal) {
    emitComment("INIT");

    emitRM("LD", 0, 0, 0, "Set the global pointer");
    emitRM("LDA", 1, endOfGlobal, 0, "set first frame at end of globals");
    emitRM("ST", 1, 0, 1, "store old fp (point to self)");

    emitComment("INIT GLOBALS AND STATICS");
    emitComment("END INIT GLOBALS AND STATICS");

    Node* mainFunc = (Node*)symbolTable.lookup("main");
    emitRM("LDA", 3, 1, 7, "Return address in ac");
    emitGotoAbs(-(mainFunc->loc + 1), "Jump to main");
    emitRO("HALT", 0, 0, 0, "DONE!");

    emitComment("END INIT");
}

void codeGen(Node* root, int endOfGlobal) {
    emitSkip(1);

    doCodeGeneration(root);
    
    genInit(endOfGlobal);
}
