#ifndef CM_H
#define CM_H

#include <map>
#include <string>
#include <iostream>
#include "symbolTable.h"
#include "scanType.h"

int run(FILE*);
int runWith(const char*);

extern Node* root;
extern int lineno;
extern int currNodeId;
extern SymbolTable symbolTable;
extern int numErrors;
extern int numWarnings;


#endif
