#include <string.h>

#include "c-.h"
#include "printtree.h"
#include "semantic.h"
#include "codegen.h"
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

FILE* code;

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

void getFileName(char*, char*);


int main (int argc, char **argv) {
    printf(""); // WTF

    char fileHandle[100];
    handleArgs(argc, argv, fileHandle);
   
    if (override) {
        runWith("test.c-");
    } else {
        if (hasFile) {
            runWith(fileHandle);
        } else {
            run(stdin);
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
        
        char name[strlen(fileHandle)];
        getFileName(fileHandle, name);
        char outputPath[strlen(fileHandle) + 3];
        sprintf(outputPath, "%s.tm", name);
        code = fopen(outputPath, "w");

        codeGen(root, globalPointer);

        //status = numErrors == 0 ? EXIT_SUCCESS : EXIT_FAILURE;
        printf("Offset for end of global space: %d\n", globalPointer);
        printf("Source: %s.c-  Object: %s.tm\n", name, name);
    } else {
        //status = EXIT_FAILURE; 
    }

    printf("Number of warnings: %d\n", numWarnings); 
    printf("Number of errors: %d\n", numErrors);

    return EXIT_SUCCESS;    
}

void getFileName(char* path, char* name) {
    printf("%s\n", path);
    bool flag = false;
    int ext = 0;
    int i;
    for (i = strlen(path); i > 0 ; i--) {
        if (!flag) {
            if (path[i] == '.') {
                flag = true;
                name[i] = '\0';
            } else {
                ext++;
            }
        } else if (path[i] != '/'){
            name[i] = path[i];
        } else if (path[i] == '/' || i == 1) {
            break;
        }
    }
    int end = strlen(path) - ext - 1;
    int start = i + 1;
    memmove(&name[0], &name[start], (end - i + 1) * sizeof(char));
}
