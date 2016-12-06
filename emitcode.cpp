//  TM Code emitting utilities
//  implementation for the TINY compiler
//  Compiler Construction: Principles and Practice
//  Kenneth C. Louden
//  Modified slightly by Jorge L. Williams
//  Modified Nov 13, 2015 Robert Heckendorn
//
//  The two comment string forms of the calls allow you to easily
//  compose a comment from text and a symbol name for example. 
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "emitcode.h"

extern FILE *code;


//  TM location number for current instruction emission
static int emitLoc = 0;
static int litLoc = 0;


//  Procedure emitComment prints a comment line 
// with a comment that is the concatenation of c and d
// 
void emitComment(char *c, char *cc)
{
    fprintf(code, "* %s %s\n", c, cc);
}

//  Procedure emitComment prints a comment line 
// with comment c in the code file
// 
void emitComment(char *c)
{
    fprintf(code, "* %s\n", c);
}



// emitRO emits a REGISTER-ONLY TM instruction
// op = the opcode
// r = target register
// s = 1st source register
// t = 2nd source register
// c = a comment to be printed if TraceCode is TRUE
// 
void emitRO(char *op, int r, int s, int t, char *c, char *cc)
{
    fprintf(code, "%3d:  %5s  %d,%d,%d\t%s %s\n", emitLoc, op, r, s, t, c, cc);
    fflush(code);
    emitLoc++;
}

void emitRO(char *op, int r, int s, int t, char *c)
{
    emitRO(op, r, s, t, c, (char *)"");
}



// emitRM emits a REGISTER-TO-MEMORY TM instruction
// op = the opcode
// r = target register
// d = the offset
// s = the base register
// c = a comment to be printed if TraceCode is TRUE
// 
void emitRM(char *op, int r, int d, int s, char *c, char *cc)
{
    fprintf(code, "%3d:  %5s  %d,%d(%d)\t%s %s\n", emitLoc, op, r, d, s, c, cc);
    fflush(code);
    emitLoc++;
}

void emitRM(char *op, int r, int d, int s, char *c)
{
    emitRM(op, r, d, s, c, (char *)"");
}


void emitGoto(int d, int s, char *c, char *cc)
{
    emitRM((char *)"LDA", PC, d, s, c, cc);
}


void emitGoto(int d, int s, char *c)
{
    emitGoto(d,  s, c, (char *)"");
}



// emitRMAbs converts an absolute reference 
// to a pc-relative reference when emitting a
// register-to-memory TM instruction
// op = the opcode
// r = target register
// a = the absolute location in memory
// c = a comment to be printed if TraceCode is TRUE
// 
void emitRMAbs(char *op, int r, int a, char *c, char *cc)
{
    fprintf(code, "%3d:  %5s  %d,%d(%d)\t%s %s\n", emitLoc, op, r, a - (emitLoc + 1),
	    PC, c, cc);
    fflush(code);
    emitLoc++;
}


void emitRMAbs(char *op, int r, int a, char *c)
{
    emitRMAbs(op, r, a, c, (char *)"");
}


void emitGotoAbs(int a, char *c, char *cc)
{
    emitRMAbs((char *)"LDA", PC, a, c, cc);
}


void emitGotoAbs(int a, char *c)
{
    emitGotoAbs(a, c, (char *)"");
}


// emit a literal instruction
void emitLit(char *s)
{
    litLoc += strlen(s);
    fprintf(code, "%3d:  %5s  \"%s\"\n", litLoc, (char *)"LIT", s);
    emitRM((char *)"LDC", 3, litLoc, 6, (char *)"Load literal value");
    litLoc++;
}


// 
//  Backpatching Functions
// 

// emitSkip skips "howMany" code
// locations for later backpatch.
// It also returns the current code position.
// emitSkip(0) tells you where you are and reserves no space.
// 
int emitSkip(int howMany)
{
    int i = emitLoc;
    emitLoc += howMany;

    return i;
}


// emitBackup backs up to 
// loc = a previously skipped location
// 
void emitBackup(int loc)
{
    emitLoc = loc;
}


// this back patches a LDA at the instruction address addr that
// jumps to the current instruction location now that it is known.
// This is essentially a backpatched "goto"
void backPatchAJumpToHere(int addr, char *comment)
{
    int currloc;

    currloc = emitSkip(0);          // remember where we are
    emitBackup(addr);               // go to addr
    emitGotoAbs(currloc, comment);  // the LDA to here
    emitBackup(currloc);            // restore addr
}


// this back patches a JZR or JNZ at the instruction address addr that
// jumps to the current instruction location now that it is known.
void backPatchAJumpToHere(char *cmd, int reg, int addr, char *comment)
{
    int currloc;

    currloc = emitSkip(0);          // remember where we are
    emitBackup(addr);               // go to addr
    emitRMAbs(cmd, reg, currloc, comment);  // cmd = JZR, JNZ
    emitBackup(currloc);            // restore addr
}


