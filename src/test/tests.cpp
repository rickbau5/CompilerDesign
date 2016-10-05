#include "util.h"
#include "c-.h"

FILE* out;

bool executeTest(const char*);

bool testVarDecl() {
    return executeTest("varDecl");
}

bool testVarDeclList() {
    return executeTest("varDeclList");
}

bool testFunctions() {
    return executeTest("functions");
}

bool testTopLevel() {
    return executeTest("topLevel");
}

bool testExpressions() {
    return executeTest("expressions");
}

bool testWhileIf() {
    return executeTest("whileif");
}

bool testSmall() {
    return executeTest("small");
}

bool testExp() {
    return executeTest("exp");
}

bool testEverything() {
    return executeTest("everything06");
}

void reset() {
    root = NULL;
    numErrors = 0;
    lineno = 1;
    currNodeId = 0;
}

int main(int argc, char **argv) {
    testVarDecl();
    testVarDeclList();
    testFunctions();
    testTopLevel();
    testExpressions();
    testWhileIf();
    testSmall();
    testExp();
    testEverything();
    return 0;
}


bool executeTest(const char* name) {
    char file[30];
    sprintf(file, "testing/%s.out", name);
    FILE* f = fopen(file, "w");
    if (f == NULL) {
        printf("Couldn't open file: [%s]\n", file);
        return false;
    }
    out = f;
    sprintf(file, "testing/%s.c-", name);
    int ret = runWith(file);

    prettyPrintTree(root);
    fprintf(f, "Number of warnings: 0\n");
    fprintf(f, "Number of errors: %d\n", numErrors);
        
    fclose(f);
    if (ret == EXIT_SUCCESS) { 
        printf("Test %s completed successfully.\n", name);
    } else {
        printf("Test %s failed.\n", name);
    }
    reset();
    return ret == EXIT_SUCCESS;
}

