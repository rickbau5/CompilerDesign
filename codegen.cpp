#include "codegen.h"

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include <vector>
#include <map>

#include "emitcode.h"
#include "c-.h"
#include "c-.tab.h"

#define ST  "ST"
#define LD  "LD"
#define LDA "LDA"
#define LDC "LDC"
#define SUB "SUB"
#define JZR "JZR"
#define ADD "ADD"
#define DIV "DIV"
#define MUL "MUL"

void doCodeGeneration(Node*);
void generateExpression(Node*);

bool onRight;

int tOffset = 0;
int fOffset = 0;
int framePointer = 0;

int _offset() {
    return framePointer + tOffset;
}

void _pfp() {
    emitCommentNumber("framePointer =", framePointer);
}

void _pto() {
    emitCommentNumber("tOffset =", tOffset);
}

bool _isGlobal(Node* node) {
    return !strcmp(node->ref, "Global");
}

bool _isLocal(Node* node) {
    return !strcmp(node->ref, "Local");
}

bool _isParam(Node* node) {
    return !strcmp(node->ref, "Param");
}

int _varRegister(Node* node) {
    return _isGlobal(node) ? 0 : 1;
}

void _storeVariable(Node* node) {
    emitRM(ST, 3, node->loc, _varRegister(node), "Store variable", (char*) node->tokenString);
}

void _loadBaseArray(Node* node, int reg) {
    char* instruction = (char*)(_isParam(node) ? LD : LDA);
    emitRM(instruction, reg, node->loc, _varRegister(node), "Load address of base of array", (char*) node->tokenString);
}

void _loadVariable(Node* node) {
    if (node->isArray) {
        _loadBaseArray(node, 3);
    } else {
        emitRM(LD, 3, node->loc, _varRegister(node), "Load variable", (char*) node->tokenString);
    }
}

void _storeArraySize(Node* node) {
    if (node->isArray) {
        emitRM(LDC, 3, node->arraySize, 6, "load size of array", (char*) node->tokenString);
        emitRM(ST, 3, node->loc + 1, _varRegister(node), "save size of array", (char*) node->tokenString);
    }
}

void _loadConstant(Node* node) {
    if (!strcmp(node->returnType, "bool")) {
        emitRM(LDC, 3, node->tokenData->bval ? 1 : 0, 6, "Load Boolean constant");
    } else if (!strcmp(node->returnType, "int")) {
        emitRM(LDC, 3, node->tokenData->ival, 6, "Load integer constant");
    } else {
        emitRM(LDC, 3, node->tokenData->cval, 6, "Load character constant");
    }
}

void _initializeVariable(Node* node) {
    tOffset--;
    doCodeGeneration(node->children[0]);
    tOffset++;
    emitRM(ST, 3, node->loc, _varRegister(node), "Store variable", (char*)node->tokenString);
}

void _computeArrayElement() {
    emitRM(LD, 4, _offset(), 1, "Load left into ac1");
    emitRO(SUB, 3, 4, 3, "compute location from index");
    emitRM(LD, 3, 0, 3, "Load array element");
}

void _computeArrayOffset(Node* node) {
    emitRM(LD, 4, framePointer, 1, "Restore index");
    _loadBaseArray(node, 5);
    emitRO(SUB, 5, 5, 4, "Compute offset of value");
}

bool _bothAreArray(Node* a, Node* b) {
    return (a->isArray && b->isArray) || (b->tokenData->tokenClass == LBRACKET && a->tokenData->tokenClass == LBRACKET);
}

void _assignmentMutator(Node* node, char* op) {
    Node* left = node->children[0];
    Node* right = node->children[1];
    if (left->nodeType != nodes::Identifier) {
        bool flag = onRight;
        if (flag)
            onRight = false;
        generateExpression(left);
        if (flag)
            onRight = true;
    }
    onRight = true;
    bool both = _bothAreArray(left, right);
    if (both) {
        tOffset--;
    }
    generateExpression(right);
    if (both) {
        tOffset++;
    }
    onRight = false;
    char* name;
    if (left->tokenData->tokenClass == LBRACKET) {
        _computeArrayOffset(left->children[0]);
        name = (char*) left->children[0]->tokenString;
    } else {
        name = (char*) left->tokenString;
    }
    int varReg = 5;
    if (_isGlobal(left)) {
        varReg = 0;
    } else if (_isLocal(left) || _isParam(left)) {
        varReg = 1;
    }
    emitRM(LD, 4, left->loc, varReg, "load lhs variable", name);
    emitRO(op, 3, 4, 3, "op", (char*) node->tokenString);
    emitRM(ST, 3, left->loc, varReg, "Store variable", name);
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
                emitCommentRight("Begin call to ", (char*) expr->tokenString);
                _pfp();

                emitRM(ST, 1, _offset(), 1, "Store old fp in ghost frame");
                int index = 1;
                framePointer -= 2;
                for (Node* n = expr->children[0]; n != NULL; n = n->sibling) {
                    char tmp[10];
                    sprintf(tmp, "%d", index);
                    emitCommentRight("Load param", tmp);
                    bool flag = onRight;
                    if (!flag)
                        onRight = true;
                    generateExpression(n);
                    if (!flag)
                        onRight = false;
                    emitRM(ST, 3, _offset() - (index - 1), 1, "Store parameter");
                    index++;
                }
                framePointer += 2;
                //tOffset += index - 1;
                emitCommentRight("Jump to", (char*) function->tokenString);
                emitRM(LDA, 1, _offset(), 1, "Load address of new frame");
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
                            sprintf(opString, "%s", ADD);
                            break;
                        case MULOP:
                            sprintf(opString, "%s", MUL);
                            break;
                        case DIVOP:
                            sprintf(opString, "%s", DIV);
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
                        case OR:
                            sprintf(opString, "%s", "OR");
                            break;
                        case AND:
                            sprintf(opString, "%s", "AND");
                            break;

                        case LBRACKET:
                            goto exit;
                        default:
                            sprintf(opString, "%s", expr->tokenString);
                            save = false;
                            break;
                    }

                    bool flag = onRight;
                    if (!flag)
                        onRight = true;
                    generateExpression(left);
                    if (save) {
                        emitRM(ST, 3, _offset(), 1, "Save left side");
                    }
                    --tOffset;
                    generateExpression(right);
                    if (!flag)
                        onRight = false;
                    ++tOffset;
                    emitRM(LD, 4, _offset(), 1, "Load left into ac1");
                    emitRO(opString, 3, 4, 3, "Op", (char*)expr->tokenString);
                    handled = true;
                } else {
                    bool flag = onRight;
                    if (!flag)
                        onRight = true;
                    generateExpression(expr->children[0]);
                    if (!flag)
                        onRight = false;
                    switch (expr->tokenData->tokenClass) {
                        case SUBOP:
                            emitRM(LDC, 4, 0, 6, "Load 0");
                            emitRO(SUB, 3, 4, 3, "Op unary", (char*) expr->tokenString);
                            break;
                        case MULOP:
                            emitRM(LD, 3, 1, 3, "Load array size");
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
            _loadConstant(expr);
            handled = true;
            break;
        case nodes::Identifier:
        case nodes::Variable:
            _loadVariable(expr);
            handled = true;
            break;

        case nodes::ReturnStatement:
        case nodes::Return:
            emitComment("RETURN");
            if (expr->children[0] != NULL) {
                onRight = true;
                generateExpression(expr->children[0]);
                onRight = false;
                emitRM(LDA, 2, 0, 3, "Copy result to rt register");
                emitRM(LD, 3, -1, 1, "Load return address");
                emitRM(LD, 1, 0, 1, "Adjust fp");
                emitRM(LDA, 7, 0, 3, "Return");
            } else {
                emitRM(LD, 3, -1, 1, "Load return address");
                emitRM(LD, 1, 0, 1, "Adjust fp");
                emitRM(LDA, 7, 0, 3, "Return");
            }
            handled = true;
            break;

        case nodes::AddAssignment: {
                _assignmentMutator(expr, ADD);
                handled = true;
            }
            break;
        case nodes::SubAssignment: {
                _assignmentMutator(expr, SUB);
                handled = true;
            }
            break;
        case nodes::MulAssignment: {
                _assignmentMutator(expr, MUL);
                handled = true;
            }
            break;
        case nodes::DivAssignment: {
                _assignmentMutator(expr, DIV);
                handled = true;
            }
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
                            _loadConstant(right);
                            _storeVariable(left);
                        } else if (right->nodeType == nodes::Identifier) {
                            bool flag = onRight;
                            if (!flag)
                                onRight = true;
                            generateExpression(right);
                            if (!flag)
                                onRight = false;
                            _storeVariable(left);
                        } else {
                            bool flag = onRight;
                            if (!flag)
                                onRight = true;
                            generateExpression(right);
                            if (!flag)
                                onRight = false;
                            _storeVariable(left);
                        }
                    } else {
                        generateExpression(left);
                            bool flag = onRight;
                            if (!flag)
                                onRight = true;
                        if (left->tokenData->tokenClass == LBRACKET)
                            tOffset--;
                        generateExpression(right);
                        if (left->tokenData->tokenClass == LBRACKET)
                            tOffset++;
                        if (!flag)
                            onRight = false;
                        Node* leftChild = left->children[0];

                        if (left->tokenData->tokenClass == LBRACKET) {
                            _computeArrayOffset(leftChild);
                        }
                        emitRM(ST, 3, 0, 5, "Store variable", (char*)leftChild->tokenString);
                    }
                    _pfp();
                }
                break;
            case LBRACKET: {
                    if (onRight) {
                        _loadBaseArray(left, 3);
                        emitRM(ST, 3, _offset(), 1, "Save left side");
                        --tOffset;
                    }
                    emitComment("Here", (char*)(onRight ? "true" : "false"));
                    generateExpression(right);
                    emitComment("Saving", (char*)(onRight ? "true" : "false"));
                    if (!onRight)
                        emitRM(ST, 3, _offset(), 1, "Save index");
                    else {
                        tOffset++;
                        _computeArrayElement();
                    }
                     
                    break;
                }
            case INC: {
                    emitRM(LD, 3, left->loc, _varRegister(left), "load lhs variable", (char*) left->tokenString);
                    emitRM(LDA, 3, 1, 3, "increment value of", (char*) left->tokenString);
                    _storeVariable(left);
                   
                    break;
                }
            case DEC: {
                    emitRM(LD, 3, left->loc, _varRegister(left), "load lhs variable", (char*) left->tokenString);
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

bool inLoop = false;
int recentLoopStart;

bool recurse = true;

void doCodeGeneration(Node* node) {
    if (node == NULL)
        return;
    switch (node->nodeType) {
        case nodes::Function: { 
                framePointer = -2;
                tOffset = 0;
                node->loc = emitSkip(0);
                emitComment("");
                emitComment("** ** ** ** ** ** ** ** ** ** ** **");
                emitComment("FUNCTION", (char*) node->tokenString);
                emitRM(ST, 3, -1, 1, "Store return address.");

                for (Node* n = node->children[0]; n != NULL; n = n->sibling) {
                    framePointer--;
                }
                emitCommentNumber("framePointer =", framePointer);

                // Function Body
                // doCodeGeneration(node->children[0]);  -- don't do parameters here?
                doCodeGeneration(node->children[1]);
                framePointer = node->memSize;

                emitComment("Add standard closing in case there is no return statement");
                emitRM(LDC, 2, 0, 6, "Set return value to 0");
                emitRM(LD, 3, -1, 1, "Load return address");
                emitRM(LD, 1, 0, 1, "Adjust fp");
                emitRM(LDA, 7, 0, 3, "Return");
                emitComment("END FUNCTION", (char*) node->tokenString);
            }
            break;
        case nodes::Compound: {
                int tOffsetBefore = tOffset;
                int before = framePointer;
                emitComment("COMPOUND");
                recurse = false;
                for (Node* n = node->children[0]; n != NULL; n = n->sibling) {
                    _storeArraySize(n);
                    if (!n->isArray) {
                        if (n->children[0] != NULL) {
                            _initializeVariable(n);
                        }
                        framePointer--;
                    } else {
                        framePointer -= n->memSize;
                    }
                }
                recurse = true;
                emitComment("Compound Body");
                doCodeGeneration(node->children[1]);
                framePointer = before;
                tOffset = tOffsetBefore;
                emitComment("END COMPOUND");
            }
            break;

        case nodes::IfStatement: {
                int skip;
                int size;
                bool hasElse = node->children[2] != NULL;

                emitComment("IF");
                doCodeGeneration(node->children[0]);
                skip = emitSkip(1);
                emitComment("THEN");
                doCodeGeneration(node->children[1]);
                size = emitSkip(0) - skip;
                emitBackup(skip);
                if (!hasElse)
                    size--;
                emitRM(JZR, 3, size , 7, "Jump around the THEN if false [backpatch]");
                emitSkip(size);
                int here = emitSkip(0);

                if (hasElse) {
                    emitComment("ELSE");
                    doCodeGeneration(node->children[2]);
                    int endif = emitSkip(0);
                    emitBackup(here - 1);
                    
                    emitRM(LDA, 7, endif - here, 7, "Jump around the ELSE [backpatch]");
                    emitBackup(endif);
                }

                emitComment("ENDIF");
            }
            break;

        case nodes::WhileStatement: {
                int skip;
                int start;
                int outerLoopStart = recentLoopStart;
                bool me = false;
                emitComment("WHILE");
                start = emitSkip(0);
                recentLoopStart = start;
                doCodeGeneration(node->children[0]);
                emitRM("JNZ", 3, 1, 7, "Jump to while part");
                skip = emitSkip(1);
                emitComment("DO");
                doCodeGeneration(node->children[1]);
                int end = emitSkip(0);
                emitRM(LDA, 7, -(end -  start + 1), 7, "go to beginning of loop");
                emitBackup(skip);
                emitRM(LDA, 7, end - emitSkip(0), 7, "Jump past loop [backpatch]");
                emitBackup(end + 1);
                recentLoopStart = outerLoopStart;
                emitComment("ENDWHILE");
            }
            break;

        case nodes::Break: {
                emitComment("BREAK");
                emitRM(LDA, 7, -(emitSkip(0) - recentLoopStart - 1), 7, "break"); 
            }
            break;
        case nodes::Identifier:
                _loadVariable(node);
            break;
        case nodes::Variable:
            if (node->inGlobal && node->nodeType == nodes::Variable) {
                // Ignore global variables here,t hey are done later.
                break;
            }
        case nodes::IncrementAssignment:
        case nodes::Operator:
            if (node->tokenData->tokenClass == LBRACKET) {
                onRight = true;
                generateExpression(node);
                onRight = false;
                break;
            }
        case nodes::FunctionCall:
        case nodes::Constant:
        case nodes::Assignment:
        case nodes::AddAssignment:
        case nodes::SubAssignment:
        case nodes::MulAssignment:
        case nodes::DivAssignment:
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

void initGlobals() {
    int gOffset = 0;

    std::vector<void*> globals = symbolTable.getAllGlobal();

    for (std::vector<void*>::iterator it = globals.begin(); it != globals.end(); it++) {
        Node* node = (Node*)*it;
        switch(node->nodeType) {
            case nodes::Function:
                // emitComment("Nothing to do for function", (char*) name.c_str());
                break;
            case nodes::Variable:
                if (node->children[0] != NULL) {
                    _initializeVariable(node);
                    gOffset--;
                } else {
                    _storeArraySize(node);
                    gOffset -= node->memSize + 1;
                }
                break;
            default:
                emitComment("No behavior defined for", (char*) node->tokenString);
                break;
        }
    }
}

void genInit(int endOfGlobal) {
    emitComment("INIT");

    emitRM(LD, 0, 0, 0, "Set the global pointer");
    emitRM(LDA, 1, endOfGlobal, 0, "set first frame at end of globals");
    emitRM(ST, 1, 0, 1, "store old fp (point to self)");

    emitComment("INIT GLOBALS AND STATICS");
    initGlobals();
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
