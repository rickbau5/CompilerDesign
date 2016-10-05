#ifndef UTILH
#define UTILH

#include <iostream>
#include "scanType.h"

extern FILE* out;

typedef struct errorContainer {
    const char* tokenString;
    int lineno;
} ErrorContainer;

const char* toString(nodes::NodeType);
void _printLevel(int);
void _prettyPrint(Node*, int);
void prettyPrintTree(Node*);
int countNodes(Node*);
const char* stringifyNode(Node*);
const char* toString(nodes::NodeType);

#endif
