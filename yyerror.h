#ifndef _YYERROR_H_
#define _YYERROR_H_

extern int lineno;               // line number
extern int numErrors;          // number of errors
extern char *yytext;           // assumes yytext is still valid from when the syntax error was found!

int split(char *s, char *strs[], char breakchar);
void initErrorProcessing();    // WARNING: must be called before any errors occur (near top of main)!
void yyerror(const char *msg);

#endif
