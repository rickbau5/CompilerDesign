#include <string.h>
#include "c-.h"
#include "util.h"
#include "stdlib.h"
#include "supgetopt.h"

FILE* out = stdout;

bool override = false;
bool hasFile = false;

extern int yydebug;

void handleArgs(int argc, char **argv, char *fileHandle) {
    extern char *optarg;
    extern int optind;

    int c;

    while (1) {
        // hunt for a string of options
        while ((c = ourGetopt(argc, argv, "d")) != EOF)
            switch (c) {
                case 'd':
                    yydebug = 1;
                    break;
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

    prettyPrintTree(root);
    if (status == EXIT_SUCCESS) {
        int warnings = 0;
        printf("Number of warnings: %d\n", warnings); 
        printErrors();
    }

    return status;    
}
