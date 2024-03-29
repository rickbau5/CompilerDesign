#include "printtree.h"
#include "semantic.h"
#include "c-.h"
#include "scanType.h"
#include <stdio.h>
#include <string.h>

void formatInfo(Node* node) {
    if (node == NULL)
        return;
    // Memory info
    if (node->hasInfo) {
        fprintf(out, "[ref: %s, size: %d, loc: %d] ", node->ref, node->memSize, node->loc);
    }

    // Type info
    if (!strcmp(node->returnType, "unknown")) {
        fprintf(out, "[undefined type] ");
    } else {
        fprintf(out, "[type %s] ", node->returnType);
    }
}

// YAY GLOBALS CAUSE C++
bool info = false;

void prettyPrintTreeWithInfo(Node* root) {
    if (root == NULL)
        return;

    info = true;
    fprintf(out, "%s ", stringifyNode(root));   
    formatInfo(root);

    fprintf(out, "[line: %d]\n", root->lineno);
    _prettyPrint(root, 0);
}

void prettyPrintTree(Node* root) {
    if (root == NULL)
        return;
    fprintf(out, "%s [line: %d]\n", stringifyNode(root), root->lineno);
    _prettyPrint(root, 0);
}

void _prettyPrint(Node* node, int level) {
    if (node == NULL) {
        return;
    }
    Node* c;
    for(int i = 0; i < node->numChildren; i++) {
        if ((c = node->children[i]) != NULL) {
            _printLevel(level); 
            fprintf(out, "!   Child: %d  %s ", i, stringifyNode(c));
            if (info) {
                formatInfo(c);
            }
            fprintf(out, "[line: %d]\n", c->lineno);
            _prettyPrint(c, level + 1);
        } 
    }
    if (node->sibling != NULL) {
        Node* sib = node->sibling;
        _printLevel(level);
        fprintf(out, "Sibling: %d  %s ", sib->siblingIndex, stringifyNode(sib));
        if (info) {
            formatInfo(sib);
        }
        fprintf(out, "[line: %d]\n", sib->lineno);
        _prettyPrint(sib, level);
    }
}

const char* stringifyNode(Node* node) {
    if (node == NULL || &(node->nodeType) == NULL) 
        return "NULL NODE";

    static char nodeString[256]; 
    for(int i = 0; i < 256; i++)
        nodeString[i] = '\0';
    switch(node->nodeType) {
        case nodes::Function:
           sprintf(nodeString, "%s %s returns type %s", toString(node->nodeType), node->tokenString, node->returnType);
           return nodeString;
        case nodes::ParamList: 
           sprintf(nodeString, "%s of type %s length %d", toString(node->nodeType), node->type, node->numChildren);
           return nodeString;
        case nodes::Parameter:
           sprintf(nodeString, "%s %s%s ", toString(node->nodeType), node->tokenString, node->isArray ? " is array" : "");
           return nodeString;
        case nodes::Variable:
           sprintf(nodeString, "%s %s%s ", toString(node->nodeType), node->tokenString, node->isArray ? " is array" : "");
           return nodeString;
        case nodes::Compound:
           return "Compound";
        case nodes::IfStatement:
           return "If";
        case nodes::WhileStatement:
           return "While";
        case nodes::Identifier:
           sprintf(nodeString, "%s: %s%s ", toString(node->nodeType), node->tokenString, node->isArray ? " is array" : "");
           return nodeString;
        case nodes::Operator:
           sprintf(nodeString, "%s: %s", toString(node->nodeType), node->tokenString);
           return nodeString;
        case nodes::Assignment:
           sprintf(nodeString, "%s: %s", toString(node->nodeType), node->tokenString);
           return nodeString;
        case nodes::AddAssignment:
        case nodes::SubAssignment:
        case nodes::MulAssignment:
        case nodes::DivAssignment:
        case nodes::IncrementAssignment:
        case nodes::DecrementAssignment:
           sprintf(nodeString, "Assign: %s", node->tokenString);
           return nodeString;
        case nodes::Constant:
           sprintf(nodeString, "%s: %s", toString(node->nodeType), node->tokenString);
           return nodeString;
        case nodes::FunctionCall:
           sprintf(nodeString, "%s: %s", toString(node->nodeType), node->tokenString);
           return nodeString;
        case nodes::Break:
           return "Break";
        case nodes::Return:
           return "Return";
        case nodes::ReturnStatement:
           return "Return";
        case nodes::Record:
           sprintf(nodeString, "%s %s ", toString(node->nodeType), node->tokenString);
           return nodeString; 

        case nodes::Error:
           sprintf(nodeString, "%s: \'%s\'", toString(node->nodeType), node->tokenString);
           return nodeString;
        case nodes::Empty:
           sprintf(nodeString, "%s", toString(node->nodeType));
           return nodeString;
        default: 
           sprintf(nodeString, "Undefined: %s at %d", toString(node->nodeType), node->lineno);
           return nodeString;
    }
    printf("Oddity: %s\n", toString(node->nodeType));
    return "nil";
}

void _printLevel(int level) {
    for (int i = 0; i < level; i++) {
        fprintf(out, "!   ");
    }
}

const char* toString(nodes::NodeType typ) {
    switch (typ) {
        case nodes::Statement: return "Statement" ; break;
        case nodes::Expression: return "Expression" ; break;
        case nodes::Function: return "Func" ; break;
        case nodes::ParamList: return "Param List" ; break;
        case nodes::Parameter: return "Param" ; break;
        case nodes::Operator:  return "Op" ; break; 
        case nodes::Identifier: return "Id" ; break;
        case nodes::Constant: return "Const" ; break;
        case nodes::Assignment: return "Assign" ; break;
        case nodes::Compound: return "Compound" ; break;
        case nodes::Variable: return "Var" ; break;
        case nodes::Type: return "type" ; break;
        case nodes::IfStatement: return "If" ; break;
        case nodes::WhileStatement: return "While" ; break;
        case nodes::FunctionCall: return "Call" ; break;
        case nodes::Break: return "Break" ; break;
        case nodes::Return: return "Return" ; break;
        case nodes::ReturnStatement: return "Return" ; break;
        case nodes::Record: return "Record" ; break;

        case nodes::Error: return "Error" ; break;
        case nodes::Empty: return "Empty" ; break;
        default:
            return "Unhandled type";
    }
}
