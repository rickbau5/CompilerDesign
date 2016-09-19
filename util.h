#ifndef UTILH
#define UTILH

#include "scanType.h"

const char* toString(nodes::NodeType);
void _printLevel(int);
void _prettyPrint(Node*, int);
void prettyPrintTree(Node*);
int countNodes(Node*);
const char* stringifyNode(Node*);
const char* toString(nodes::NodeType);

#endif
