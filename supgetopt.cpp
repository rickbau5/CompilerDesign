// 									
//  ourGetopt.c:	Derived from AT&T public domain source of ourGetopt(3),	
// 		modified for use with MS C 6.0 on MS DOS systems. For	
// 		unknown reasons the variable optopt is exported here.	
// 									
// 	Note that each option may occur more than once in the command	
// 	line, this may require special action like occurence counting.	
// 	Each option is indicated by a single character in opts string	
// 	followed by : if an option argument is required. So for "abo:"
// 	the following combinations are possible:			
// 		-a -b -o value	sets a, b, and argument value for o	
// 		-ab -o value	equivalent				
// 		-ab -ovalue	equivalent, but not recommended 	
// 		-abovalue	equivalent, but not recommended 	
// 		-a -- -b	sets only a, optind advanced to -b	
// 		-a - -b 	sets only a, optind stays at single -	
// 		-A		error message for A, returned as ?	
// 		-o		error message if no more arguments	
// 									
//  example code:							
// 	...								
// 	extern int ourGetopt( int, char **, char*);			
// 	...								
// 	int main( int argc, char *argv[] )				
// 	{								
// 		extern int   opterr;					
// 		extern int   optind;					
// 		extern char *optarg;					
// 		int c,	aset = 0,  bset = 0;				
// 		char *oarg = NULL;					
// 									
// 		while (( c == ourGetopt( argc, argv, "abo:" ) != -1 ) {
// 		switch ( c )						
// 		{	case 'a':                                     
// 				++aset; 	break;		
// 			case 'b':                                     
// 				++bset; 	break;		
// 			case 'o':                                     
// 				oarg = optarg;	break;		
// 			default:					
// 			       ...		return 1;		
//
//                case '?': NOT EXPLICITLY NEEDED WITH DEFAULT    
//		     
//                case ':': WILL NEVER HAPPEN, ':' NOT ALLOWED    
//
//                case '-': WILL NEVER HAPPEN, '-' NOT ALLOWED 
//              }                                                       
//            }
//              ...                                                     
//      }                                                               
//
//

#include	<cstring.h>
#include	<stdio.h>

#if	M_I8086 || M_I286 || MSDOS	/* test Microsoft C definitions */
#define 	SWITCH	'/'	/* /: only used for DOS */
#else
#define 	SWITCH	'-'	/* -: always recognized */
#endif

/* ------------ EXPORT variables -------------------------------------- */

char *optarg;			/* option argument if : in opts */
int optind = 1;			/* next argv index              */
int opterr = 1;			/* show error message if not 0  */
int optopt;			/* last option (export dubious) */

/* ------------ private section --------------------------------------- */

static int sp = 1;		/* offset within option word    */

static int badopt(char *name, char *text)
{
    if (opterr)			/* show error message if not 0      */
	fprintf(stderr, "%s: %s -- %c\n", name, text, optopt);

    return (int) '?';		/* ?: result for invalid option */
}

/* ------------ EXPORT function --------------------------------------- */

int ourGetopt(int argc, char **argv, char *opts)
{
    char *cp, ch;

    if (sp == 1) {
	if (argc <= optind || argv[optind][1] == '\0')
	    return EOF;		/* no more words or single '-'  */


	if ((ch = argv[optind][0]) != '-' && ch != SWITCH)
	    return EOF;		/* options must start with '-'  */

	if (!strcmp(argv[optind], "--")) {
	    ++optind;		/* to next word */
	    return EOF;		/* -- marks end */
	}
    }

    optopt = (int) (ch = argv[optind][sp]);	/* flag option  */

    if (ch == ':' || (cp = strchr(opts, ch)) == NULL) {
	if (argv[optind][++sp] == '\0') {
	    ++optind;
	    sp = 1;		/* to next word */
	}

	return badopt(argv[0], "illegal option");
    }

    if (*++cp == ':') {		/* ':' option requires argument */
	optarg = &argv[optind][sp + 1];	/* if same word */
	++optind;
	sp = 1;			/* to next word */

	if (*optarg == '\0') {	/* in next word */
	    if (argc <= optind)	/* no more word */
		return badopt(argv[0], "option requires an argument");

	    optarg = argv[optind++];	/* to next word */
	}
    }
    else {			/* flag option without argument */
	optarg = NULL;

	if (argv[optind][++sp] == '\0') {
	    optind++;
	    sp = 1;		/* to next word */
	}
    }

    return optopt;
}

#include <stdlib.h>
#include <stdio.h>
#include <strings.h>

// this program reads in a command line
// aflg gets set if there is a -a option
// bflg gets set if there is a -b option
// zflg gets set if there is a -z option
//
// a and b options are mutually exclusive
// z prints out when it is discovered
// o option takes a file name and prints out when it is discovered
// extraneous words are considered files are printed out
//
// this program was "borrowed" and modified from the Sun Solaris man
// page for educational purposes only.
//
//  compile:  g++ ourGetopt.cpp
//  test: a.out  ali -a bob -z -z carol -z -o don ella -o frida gill
//
// Robert Heckendorn  Mar 6, 2006
//
int main(int argc, char **argv)
{
    int c;
    extern char *optarg;
    extern int optind;
    int aflg, bflg, zflg;
    int errflg;
    char *ofile;

    aflg = bflg = zflg = errflg = 0;
    ofile = NULL;

    while (1) {

        // hunt for a string of options
        while ((c = ourGetopt(argc, argv, "abo:z")) != EOF)
            switch (c) {
            case        'a':
                if (bflg) errflg = 1;
                else aflg = 1;
                break;
            case        'b':
                if (aflg) errflg = 1;
                else bflg = 1;
                break;
            case        'o':
		if (ofile) {
		    printf("-o option can be used only once.  Last use is used.\n");
		}
                ofile = strdup(optarg);
                printf("ofile = %s\n", ofile);
                break;
            case        'z':
		zflg = 1;
                printf("option Z!\n");
                break;
            case        '?':
                errflg = 1;
            }

        // report any errors or usage request
        if (errflg) {
            (void)fprintf(stderr, "usage: cmd [-a|-b] [-z] [-o <filename>] files...\n");
            exit(2);
        }

        // pick off a nonoption
        if (optind < argc) {
            (void)printf("file: %s\n", argv[optind]);
            optind++;
        }
        else {
            break;
        }
    }

    if (aflg) printf("option 'a' was found\n");
    if (bflg) printf("option 'b' was found\n");
    if (zflg) printf("option 'z' was found\n");
    if (ofile) printf("option 'o' was found for file %s\n", ofile);

    return 0;
}

