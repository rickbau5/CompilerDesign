#ifndef CM_H
#define CM_H

#include <map>
#include <string>
#include <iostream>
#include "scanType.h"

#define MAX_ERRORS 256

int run(FILE*);
int runWith(const char*);

void printErrors();

extern Node* root;
extern int numErrors;
extern int lineno;
extern int currNodeId;
extern std::map<std::string, TokenData*> recordTable;

#endif
