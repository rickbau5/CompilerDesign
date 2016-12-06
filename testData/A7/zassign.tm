* C- compiler version C-F16
* Built: Nov 13, 2016
* Author: Robert B. Heckendorn
* File compiled:  zassign.c-
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION input
  1:     ST  3,-1(1)	Store return address 
  2:     IN  2,2,2	Grab int input 
  3:     LD  3,-1(1)	Load return address 
  4:     LD  1,0(1)	Adjust fp 
  5:    LDA  7,0(3)	Return 
* END FUNCTION input
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION output
  6:     ST  3,-1(1)	Store return address 
  7:     LD  3,-2(1)	Load parameter 
  8:    OUT  3,3,3	Output integer 
  9:    LDC  2,0(6)	Set return to 0 
 10:     LD  3,-1(1)	Load return address 
 11:     LD  1,0(1)	Adjust fp 
 12:    LDA  7,0(3)	Return 
* END FUNCTION output
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION inputb
 13:     ST  3,-1(1)	Store return address 
 14:    INB  2,2,2	Grab bool input 
 15:     LD  3,-1(1)	Load return address 
 16:     LD  1,0(1)	Adjust fp 
 17:    LDA  7,0(3)	Return 
* END FUNCTION inputb
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION outputb
 18:     ST  3,-1(1)	Store return address 
 19:     LD  3,-2(1)	Load parameter 
 20:   OUTB  3,3,3	Output bool 
 21:    LDC  2,0(6)	Set return to 0 
 22:     LD  3,-1(1)	Load return address 
 23:     LD  1,0(1)	Adjust fp 
 24:    LDA  7,0(3)	Return 
* END FUNCTION outputb
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION inputc
 25:     ST  3,-1(1)	Store return address 
 26:    INC  2,2,2	Grab char input 
 27:     LD  3,-1(1)	Load return address 
 28:     LD  1,0(1)	Adjust fp 
 29:    LDA  7,0(3)	Return 
* END FUNCTION inputc
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION outputc
 30:     ST  3,-1(1)	Store return address 
 31:     LD  3,-2(1)	Load parameter 
 32:   OUTC  3,3,3	Output char 
 33:    LDC  2,0(6)	Set return to 0 
 34:     LD  3,-1(1)	Load return address 
 35:     LD  1,0(1)	Adjust fp 
 36:    LDA  7,0(3)	Return 
* END FUNCTION outputc
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION outnl
 37:     ST  3,-1(1)	Store return address 
 38:  OUTNL  3,3,3	Output a newline 
 39:     LD  3,-1(1)	Load return address 
 40:     LD  1,0(1)	Adjust fp 
 41:    LDA  7,0(3)	Return 
* END FUNCTION outnl
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION main
 42:     ST  3,-1(1)	Store return address. 
* COMPOUND
 43:    LDC  3,10(6)	load size of array a
 44:     ST  3,-4(1)	save size of array a
* Compound Body
* EXPRESSION
 45:    LDC  3,666(6)	Load integer constant 
 46:     ST  3,-2(1)	Store variable x
* EXPRESSION
 47:     LD  3,-2(1)	Load variable x
 48:     ST  3,-3(1)	Store variable y
* EXPRESSION
*                       Begin call to  output
 49:     ST  1,-15(1)	Store old fp in ghost frame 
*                       Load param 1
 50:     LD  3,-3(1)	Load variable y
 51:     ST  3,-17(1)	Store parameter 
*                       Jump to output
 52:    LDA  1,-15(1)	Load address of new frame 
 53:    LDA  3,1(7)	Return address in ac 
 54:    LDA  7,-49(7)	CALL output
 55:    LDA  3,0(2)	Save the result in ac 
*                       End call to output
* EXPRESSION
 56:    LDC  3,4(6)	Load integer constant 
 57:     ST  3,-15(1)	Save left side 
 58:    LDC  3,5(6)	Load integer constant 
 59:     LD  4,-15(1)	Load left into ac1 
 60:    ADD  3,4,3	Op + 
 61:     ST  3,-15(1)	Save index 
 62:    LDC  3,777(6)	Load integer constant 
 63:     LD  4,-15(1)	Restore index 
 64:    LDA  5,-5(1)	Load address of base of array a
 65:    SUB  5,5,4	Compute offset of value 
 66:     ST  3,0(5)	Store variable a
* EXPRESSION
 67:    LDA  3,-5(1)	Load address of base of array a
 68:     ST  3,-15(1)	Save left side 
 69:    LDC  3,4(6)	Load integer constant 
 70:     ST  3,-16(1)	Save left side 
 71:    LDC  3,5(6)	Load integer constant 
 72:     LD  4,-16(1)	Load left into ac1 
 73:    ADD  3,4,3	Op + 
 74:     LD  4,-15(1)	Load left into ac1 
 75:    SUB  3,4,3	compute location from index 
 76:     LD  3,0(3)	Load array element 
 77:     ST  3,-3(1)	Store variable y
* EXPRESSION
*                       Begin call to  output
 78:     ST  1,-15(1)	Store old fp in ghost frame 
*                       Load param 1
 79:     LD  3,-3(1)	Load variable y
 80:     ST  3,-17(1)	Store parameter 
*                       Jump to output
 81:    LDA  1,-15(1)	Load address of new frame 
 82:    LDA  3,1(7)	Return address in ac 
 83:    LDA  7,-78(7)	CALL output
 84:    LDA  3,0(2)	Save the result in ac 
*                       End call to output
* END COMPOUND
* Add standard closing in case there is no return statement
 85:    LDC  2,0(6)	Set return value to 0 
 86:     LD  3,-1(1)	Load return address 
 87:     LD  1,0(1)	Adjust fp 
 88:    LDA  7,0(3)	Return 
* END FUNCTION main
  0:    LDA  7,88(7)	Jump to init [backpatch] 
* INIT
 89:     LD  0,0(0)	Set the global pointer 
 90:    LDA  1,0(0)	set first frame at end of globals 
 91:     ST  1,0(1)	store old fp (point to self) 
* INIT GLOBALS AND STATICS
* END INIT GLOBALS AND STATICS
 92:    LDA  3,1(7)	Return address in ac 
 93:    LDA  7,-52(7)	Jump to main 
 94:   HALT  0,0,0	DONE! 
* END INIT
