#include "c-.h"
#include "util.h"

FILE* out = stdout;

bool override = false;

int main (int argc, char **argv) {
    printf("here"); // WTF
   
    int status;
    if (override) {
        status = runWith("test.c-");
    } else {
        if (argc > 1) {
            status = runWith(argv[1]);
        } else {
            status = run(stdin);
        }
    }

    if (status == EXIT_SUCCESS) {
        prettyPrintTree(root);
        printErrors();
    }

    return status;    
}
