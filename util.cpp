#include "util.h"
#include "scanType.h"
#include <stdio.h>

void prettyPrintTree(Node* root) {
    printf("%s [line: %d]\n", stringifyNode(root), root->lineno);
    _prettyPrint(root, 0);
    puts("");
}

void _prettyPrint(Node* node, int level) {
    if (node != NULL) {
        Node* c;
        for (int i = 0; i < node->numChildren; i++) {
            if ((c = node->children[i]) != NULL) {
                _printLevel(level); 
                printf("|  Child: %d  %s [line: %d]\n", i, stringifyNode(c), c->lineno);
                _prettyPrint(c, level + 1);
            }
        }
        if (node->sibling != NULL) {
            _printLevel(level);
            Node* sib = node->sibling;
            printf("|Sibling: %d  %s [line: %d]\n", sib->siblingIndex, stringifyNode(sib), sib->lineno);
            _prettyPrint(node->sibling, level);
        }
    } else {
        ;
    }
}

const char* stringifyNode(Node* node) {
    static char nodeString[60]; 
    switch(node->nodeType) {
        case nodes::Function:
           sprintf(nodeString, "%s %s returns type %s", toString(node->nodeType), node->tokenString, node->returnType);
           return nodeString;
        case nodes::ParamList: 
           sprintf(nodeString, "%s of type %s length %d", toString(node->nodeType), node->type, node->numChildren);
           return nodeString;
        case nodes::Parameter:
           sprintf(nodeString, "%s %s of type %s", toString(node->nodeType), node->tokenString, node->type);
           return nodeString;
        default: return "Undefined";
            
    }
    return "";
}

void _printLevel(int level) {
    for (int i = 0; i < level; i++) {
        printf("|  ");
    }
}

int countNodes(Node* node) {
    if (node != NULL) {
        int sibs = 0;
        int children = 0;

        if (node->sibling != NULL) {
            sibs = countNodes(node->sibling);
        }
        int idx = 0;
        Node* t;
        while ((t = node->children[idx++]) != NULL) {
            children += countNodes(t);
        }
        return 1 + sibs + children;
    } else {
        return 0;
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
    }
}
