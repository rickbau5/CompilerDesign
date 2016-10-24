#include	<string.h>
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

	return badopt(argv[0], strdup("illegal option"));
    }

    if (*++cp == ':') {		/* ':' option requires argument */
	optarg = &argv[optind][sp + 1];	/* if same word */
	++optind;
	sp = 1;			/* to next word */

	if (*optarg == '\0') {	/* in next word */
	    if (argc <= optind)	/* no more word */
		return badopt(argv[0], strdup("option requires an argument"));

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

