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
int numErrors = 0;
int numWarnings = 0;
int globalPointer = 0;

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

        Node* start = root;
        for (int i = 0; i < 7; i++) {
            start = start->sibling;
        }
        analyzeAST(start);
        if (printTypedTree) {
            prettyPrintTreeWithInfo(root);
        }
        status = numErrors == 0 ? EXIT_SUCCESS : EXIT_FAILURE;
        printf("Offset for end of global space: %d\n", globalPointer);
        char fileName[strlen(fileHandle)];
        bool flag = false;
        int lngth;
        int ext = 0;
        for (int i = strlen(fileHandle); i > 0 ; i--) {
            if (!flag) {
                if (fileHandle[i] == '.') {
                    flag = true;
                    fileName[i] = '\0';
                } else {
                    ext++;
                }
            } else if (fileHandle[i] != '/'){
                fileName[i] = fileHandle[i];
            } else if (fileHandle[i] == '/' || i == 1) {
                lngth = strlen(fileHandle) - i - ext - 1;
                break;
            }
        }
        printf("Source: %s.c-  Object: %s.tm\n", &(fileName[strlen(fileHandle) - lngth - ext]), &(fileName[strlen(fileHandle) - lngth - ext]));
    } else {
        status = EXIT_FAILURE; 
    }

    printf("Number of warnings: %d\n", numWarnings); 
    printf("Number of errors: %d\n", numErrors);

    return EXIT_SUCCESS;    
}
