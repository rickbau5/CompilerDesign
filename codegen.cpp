#include "codegen.h"

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "emitcode.h"
#include "c-.h"
#include "c-.tab.h"

#define ST  "ST"
#define LD  "LD"
#define LDA "LDA"
#define LDC "LDC"
#define SUB "SUB"
#define JZR "JZR"

void doCodeGeneration(Node*);

int framePointer;
bool onRight;

int tmpStack = 0;

void _storeVariable(Node* node) {
    int s = !strcmp(node->ref, "Global") ? 0 : 1;
    emitRM(ST, 3, node->loc, s, "Store variable", (char*) node->tokenString);
}

void generateExpression(Node* expr) {
    if (expr == NULL) // Unary operators
        return;

    Node* left = expr->children[0];
    Node* right = expr->children[1];

    bool handled = false;
    switch (expr->nodeType) {
        case nodes::FunctionCall: {
                Node* function = (Node*)symbolTable.lookup(expr->tokenString);
                emitCommentRight("Begin call to", (char*) expr->tokenString);

                emitRM(ST, 1, framePointer - tmpStack, 1, "Store old fp in ghost frame");
                framePointer -= 2; // Advance framepointer
                int index = 1;
                for (Node* n = expr->children[0]; n != NULL; n = n->sibling) {
                    if (n->nodeType == nodes::Variable) {
                        emitRM(LD, 3, n->loc, 1, "Load variable", (char*) n->tokenString);
                        emitRM(ST, 3, framePointer - tmpStack, 1, "Store parameter");
                    } else {
                        char tmp[10];
                        sprintf(tmp, "%d", index++);
                        emitCommentRight("Load param", tmp);
                        generateExpression(n);
                        emitRM(ST, 3, framePointer - tmpStack, 1, "Store parameter");
                        tmpStack++;
                    }
                }
                tmpStack -= index - 1;
                framePointer += 2;
                emitCommentRight("Jump to", (char*) function->tokenString);
                emitRM(LDA, 1, framePointer - tmpStack, 1, "Load address of new frame");
                emitRM(LDA, 3, 1, 7, "Return address in ac");
                // emitRM(LDA, 7, -emitSkip(0) - function->loc - 2, 7, "CALL", (char*) expr->tokenString);
                // emitRM(LDA, 7, function->loc, 7, "CALL", (char*) mainFunc->tokenString);
                emitGotoAbs(function->loc, "CALL", (char*) function->tokenString);
                //emitGotoAbs(function->loc, "CALL", (char*) function->tokenString);
                emitRM(LDA, 3, 0, 2, "Save the result in ac");

                emitCommentRight("End call to", (char*) expr->tokenString);
                handled = true;
            }
            break;
        case nodes::Operator: {
                if (expr->children[1] != NULL) {
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
                            sprintf(opString, "%s", SUB);
                            break;
                        case LESS:
                            sprintf(opString, "%s", "TLT");
                            break;
                        case LESSEQ:
                            sprintf(opString, "%s", "TLE");
                            break;
                        case GRTR:
                            sprintf(opString, "%s", "TGT");
                            break;
                        case GRTEQ:
                            sprintf(opString, "%s", "TGE");
                            break;
                        case EQ:
                            sprintf(opString, "%s", "TEQ");
                            break;
                        case NOTEQ:
                            sprintf(opString, "%s", "TNE");
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
                        emitRM(ST, 3, framePointer - tmpStack, 1, "Save left side");
                    }
                    tmpStack++;
                    generateExpression(right);
                    tmpStack--;
                    emitRM(LD, 4, framePointer - tmpStack, 1, "Load left into ac1");
                    emitRO(opString, 3, 4, 3, "Op", (char*)expr->tokenString);
                    handled = true;
                } else {
                    emitRM(LD, 3, left->loc, 1, "Load variable", (char*)left->tokenString);
                    switch (expr->tokenData->tokenClass) {
                        case SUBOP:
                            emitRM(LDC, 4, 0, 6, "Load 0");
                            emitRO(SUB, 3, 4, 3, "Op unary", (char*) expr->tokenString);
                            break;
                        default:
                            emitComment("Unknown unary op:", (char*)expr->tokenString);
                            break;
                    }
                    handled = true;
                }
            }
            break;

        case nodes::Constant:
            if (!strcmp(expr->returnType, "bool")) {
                emitRM(LDC, 3, expr->tokenData->bval ? 1 : 0, 6, "Load Boolean constant");
            
            } else if (!strcmp(expr->returnType, "integer")) {
                emitRM(LDC, 3, expr->tokenData->ival, 6, "Load integer constant");
            } else {
                emitRM(LDC, 3, expr->tokenData->cval, 6, "Load character constant"); 
            }
            handled = true;
            break;
        case nodes::Identifier:
        case nodes::Variable:
            emitRM(LD, 3, expr->loc, 1, "Load variable", (char*)expr->tokenString);
            handled = true;
            break;

        case nodes::ReturnStatement:
        case nodes::Return:
            emitComment("RETURN");
            generateExpression(expr->children[0]);
            emitRM(LDA, 2, 0, 3, "Copy result to rt register");
            emitRM(LD, 3, -1, 1, "Load return address");
            emitRM(LD, 1, 0, 1, "Adjust fp");
            emitRM(LDA, 7, 0, 3, "Return");
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
                            emitRM(LDC, 3, right->intValue, 6, "Load integer constant");
                            _storeVariable(left);
                        } else if (right->nodeType == nodes::Identifier) {
                            emitRM(LD, 3, right->loc, 1, "Load variable", (char*) right->tokenString);
                            _storeVariable(left);
                        } else {
                            onRight = true;
                            generateExpression(right);
                            onRight = false;

                            if (right->tokenData->tokenClass == LBRACKET) {
                                emitRM(LD, 4, framePointer, 1, "Load left into ac1");
                                emitRO(SUB, 3, 4, 3, "compute location from index");
                                emitRM(LD, 3, 0, 3, "Load array element");
                                _storeVariable(left);
                            }
                        }
                    } else {
                        generateExpression(left);
                        generateExpression(right);

                        if (left->tokenData->tokenClass == LBRACKET) {
                            emitRM(LD, 4, -15, 1, "Restore index");
                            emitRM(LDA, 5, left->children[0]->loc, 1, "Load address of base of array", (char*) left->children[0]->tokenString);
                            emitRO(SUB, 5, 5, 4, "Compute offset of value");
                        }
                        emitRM(ST, 3, 0, 5, "Store variable", (char*)left->children[0]->tokenString);
                    }
                }
                break;
            case LBRACKET: {
                    if (onRight) {
                        emitRM(LDA, 3, left->loc, 1, "Load address of base of array");
                        emitRM(ST, 3, framePointer, 1, "Save left side");
                        --framePointer;
                    }
                    generateExpression(right);
                    if (!onRight)
                        emitRM(ST, 3, -15, 1, "Save index");
                    else 
                        framePointer++;
                     
                    break;
                }
            case INC: {
                    emitRM(LD, 3, left->loc, 1, "load lhs variable", (char*) left->tokenString);
                    emitRM(LDA, 3, 1, 3, "increment value of", (char*) left->tokenString);
                    _storeVariable(left);
                   
                    break;
                }
            case DEC: {
                    emitRM(LD, 3, left->loc, 1, "load lhs variable", (char*) left->tokenString);
                    emitRM(LDA, 3, -1, 3, "decrement value of", (char*) left->tokenString);
                    _storeVariable(left);
                    break;
                }
            default:
                emitComment("Unimplemented expr", (char*) expr->tokenString);
                break;
        }
    }
}

void pimpIO();

void doCodeGeneration(Node* node) {
    if (node == NULL)
        return;
    switch (node->nodeType) {
        case nodes::Function: { 
                framePointer = node->memSize;
                node->loc = emitSkip(0);
                emitComment("");
                emitComment("** ** ** ** ** ** ** ** ** ** ** **");
                emitComment("FUNCTION", (char*) node->tokenString);
                emitRM(ST, 3, -1, 1, "Store return address.");

                // Function Body
                // doCodeGeneration(node->children[0]);  -- don't do parameters here?
                doCodeGeneration(node->children[1]);

                emitComment("Add standard closing in case there is no return statement");
                emitRM(LDC, 2, 0, 6, "Set return value to 0");
                emitRM(LD, 3, -1, 1, "Load return address");
                emitRM(LD, 1, 0, 1, "Adjust fp");
                emitRM(LDA, 7, 0, 3, "Return");
                emitComment("END FUNCTION", (char*) node->tokenString);
            }
            break;
        case nodes::Compound: {
                int before = framePointer;
                emitComment("COMPOUND");
                for (Node* n = node->children[0]; n != NULL; n = n->sibling) {
                    if (n->isArray) {
                        emitRM(LDC, 3, n->arraySize, 6, "load size of array", (char*) n->tokenString);
                        emitRM(ST, 3, -4, 1, "save size of array", (char*) n->tokenString);
                    }
                }
                emitComment("Compound Body");
                doCodeGeneration(node->children[1]);
                framePointer = before;
                emitComment("END COMPOUND");
            }
            break;

        case nodes::IfStatement: {
                int skip;
                int size;

                emitComment("IF");
                generateExpression(node->children[0]);
                skip = emitSkip(1);
                emitComment("THEN");
                generateExpression(node->children[1]);
                size = emitSkip(0) - skip;
                emitBackup(skip);
                emitRM(JZR, 3, size, 7, "Jump around the THEN if false [backpatch]");
                emitSkip(size);
                int here = emitSkip(0);

                emitComment("ELSE");
                generateExpression(node->children[2]);
                int endif = emitSkip(0);
                emitBackup(here - 1);
                
                emitRM(LDA, 7, endif - here, 7, "Jump around the ELSE [backpatch]");
                emitBackup(endif);

                emitComment("ENDIF");
            }
            break;

        case nodes::Parameter: {
                emitRM(LD, 3, -2, 1, "Load parameter");
            }
            break;
        case nodes::IncrementAssignment:
        case nodes::Operator:
        case nodes::FunctionCall:
        case nodes::Assignment:
            emitComment("EXPRESSION");
            generateExpression(node);
            break;

        case nodes::ReturnStatement:
        case nodes::Return:
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

    emitRM(LD, 0, 0, 0, "Set the global pointer");
    emitRM(LDA, 1, endOfGlobal, 0, "set first frame at end of globals");
    emitRM(ST, 1, 0, 1, "store old fp (point to self)");

    emitComment("INIT GLOBALS AND STATICS");
    emitComment("END INIT GLOBALS AND STATICS");

    Node* mainFunc = (Node*)symbolTable.lookup("main");
    emitRM(LDA, 3, 1, 7, "Return address in ac");
    emitGotoAbs(mainFunc->loc, "Jump to main");
    emitRO("HALT", 0, 0, 0, "DONE!");

    emitComment("END INIT");
}

void codeGen(Node* root, int endOfGlobal) {
    emitSkip(1);

    pimpIO();

    for (int i = 0; i < 7; i++)
        root = root->sibling;

    doCodeGeneration(root);
    backPatchAJumpToHere(0, "Jump to init [backpatch]");
    
    genInit(endOfGlobal);
}

void _stdHeading(bool param, char* funcName) {
    emitComment("");
    emitComment("** ** ** ** ** ** ** ** ** ** ** **");
    emitComment("FUNCTION", funcName);
    emitRM(ST, 3, -1, 1, "Store return address");
    if (param)
        emitRM(LD, 3, -2, 1, "Load parameter");
}

void _stdFooter(bool isVoid, char* funcName) {
    if (isVoid)
        emitRM(LDC, 2, 0, 6, "Set return to 0");
    emitRM(LD, 3, -1, 1, "Load return address");
    emitRM(LD, 1, 0, 1, "Adjust fp");
    emitRM(LDA, 7, 0 , 3, "Return");
    emitComment("END FUNCTION", funcName);
}

void _genInput(char* op, char* funcName, char* comment) {
    _stdHeading(false, funcName);
    emitRO(op, 2, 2, 2, comment);
    _stdFooter(false, funcName);
}

void _genOutput(char* op, char* funcName, char* comment) {
    _stdHeading(true, funcName);
    emitRO(op, 3, 3, 3, comment);
    _stdFooter(true, funcName);
}

Node* _addLocAndAdvance(Node* function) {
    function->loc = emitSkip(0);
    return function->sibling;
}

void pimpIO() {
    Node* ioFunction = root;
    ioFunction = _addLocAndAdvance(ioFunction);
    _genInput("IN", "input", "Grab int input");
    ioFunction = _addLocAndAdvance(ioFunction);
    _genOutput("OUT", "output", "Output integer");
    ioFunction = _addLocAndAdvance(ioFunction);
    _genInput("INB", "inputb", "Grab bool input");
    ioFunction = _addLocAndAdvance(ioFunction);
    _genOutput("OUTB", "outputb", "Output bool");
    ioFunction = _addLocAndAdvance(ioFunction);
    _genInput("INC", "inputc", "Grab char input");
    ioFunction = _addLocAndAdvance(ioFunction);
    _genOutput("OUTC", "outputc", "Output char");
    
    ioFunction = _addLocAndAdvance(ioFunction);
    _stdHeading(false, "outnl");
    emitRO("OUTNL", 3, 3, 3, "Output a newline");
    emitRM(LD, 3, -1, 1, "Load return address");
    emitRM(LD, 1, 0, 1, "Adjust fp");
    emitRM(LDA, 7, 0 , 3, "Return");
    emitComment("END FUNCTION", "outnl");
}
