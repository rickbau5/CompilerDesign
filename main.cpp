#include "c-.h"
#include "util.h"

FILE* out = stdout;

bool override = false;

int main (int argc, char **argv) {
    printf(""); // WTF
   
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

    prettyPrintTree(root);
    if (status == EXIT_SUCCESS) {
        int warnings = 0;
        printf("Number of warnings: %d\n", warnings); 
        printErrors();
    }

    return status;    
}
