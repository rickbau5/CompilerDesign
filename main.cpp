#include <string.h>
#include "c-.h"
#include "printtree.h"
#include "semantic.h"
#include "stdlib.h"
#include "supgetopt.h"

FILE* out = stdout;

bool override = false;
bool hasFile = false;
bool printTree = false;
bool printTypedTree = false;

extern int yydebug;
extern int numErrors;

void handleArgs(int argc, char **argv, char *fileHandle) {
    extern char *optarg;
    extern int optind;

    int c;
    char* ops = strdup("dpP");
    while (1) {
        // hunt for a string of options
        while ((c = ourGetopt(argc, argv, ops)) != EOF)
            switch (c) {
                case 'd':
                    yydebug = 1;
                    break;
                case 'p':
                    printTree = true;
                    break;
                case 'P':
                    printTypedTree = true;
                case '?':
                    ;
            }

        // pick off a nonoption
        if (optind < argc) {
            hasFile = true;
            strcpy(fileHandle, argv[optind]);
            optind++;
        }
        else {
            break;
        }
    }
}

int main (int argc, char **argv) {
    printf(""); // WTF

    char fileHandle[100];
    handleArgs(argc, argv, fileHandle);
   
    int status;
    if (override) {
        status = runWith("test.c-");
    } else {
        if (hasFile) {
            status = runWith(fileHandle);
        } else {
            status = run(stdin);
        }
    }


    bool hasSyntaxErrors = numErrors != 0;

    if (!hasSyntaxErrors) {
        if (printTree) {
            prettyPrintTree(root);
        }

        analyzeAST(root);
        if (printTypedTree) {
            prettyPrintTreeWithTypes(root);
        }
        status = numErrors == 0 ? EXIT_SUCCESS : EXIT_FAILURE;
    } else {
        status = EXIT_FAILURE; 
    }

    int warnings = 0;
    printf("Number of warnings: %d\n", warnings); 
    printf("Number of errors: %d\n", numErrors);

    return status;    
}
