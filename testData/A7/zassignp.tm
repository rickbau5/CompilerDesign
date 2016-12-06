* C- compiler version C-F16
* Built: Nov 13, 2016
* Author: Robert B. Heckendorn
* File compiled:  zassignp.c-
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
* FUNCTION fred
 42:     ST  3,-1(1)	Store return address. 
* COMPOUND
* Compound Body
* EXPRESSION
 43:    LDC  3,666(6)	Load integer constant 
 44:     ST  3,-2(1)	Store variable x
* EXPRESSION
 45:     LD  3,-2(1)	Load variable x
 46:     ST  3,-3(1)	Store variable y
* EXPRESSION
*                       Begin call to  output
 47:     ST  1,-5(1)	Store old fp in ghost frame 
*                       Load param 1
 48:     LD  3,-3(1)	Load variable y
 49:     ST  3,-7(1)	Store parameter 
*                       Jump to output
 50:    LDA  1,-5(1)	Load address of new frame 
 51:    LDA  3,1(7)	Return address in ac 
 52:    LDA  7,-47(7)	CALL output
 53:    LDA  3,0(2)	Save the result in ac 
*                       End call to output
* EXPRESSION
 54:    LDC  3,4(6)	Load integer constant 
 55:     ST  3,-5(1)	Save left side 
 56:    LDC  3,5(6)	Load integer constant 
 57:     LD  4,-5(1)	Load left into ac1 
 58:    ADD  3,4,3	Op + 
 59:     ST  3,-5(1)	Save index 
 60:    LDC  3,777(6)	Load integer constant 
 61:     LD  4,-5(1)	Restore index 
 62:     LD  5,-4(1)	Load address of base of array a
 63:    SUB  5,5,4	Compute offset of value 
 64:     ST  3,0(5)	Store variable a
* EXPRESSION
 65:     LD  3,-4(1)	Load address of base of array a
 66:     ST  3,-5(1)	Save left side 
 67:    LDC  3,4(6)	Load integer constant 
 68:     ST  3,-6(1)	Save left side 
 69:    LDC  3,5(6)	Load integer constant 
 70:     LD  4,-6(1)	Load left into ac1 
 71:    ADD  3,4,3	Op + 
 72:     LD  4,-5(1)	Load left into ac1 
 73:    SUB  3,4,3	compute location from index 
 74:     LD  3,0(3)	Load array element 
 75:     ST  3,-3(1)	Store variable y
* EXPRESSION
*                       Begin call to  output
 76:     ST  1,-5(1)	Store old fp in ghost frame 
*                       Load param 1
 77:     LD  3,-3(1)	Load variable y
 78:     ST  3,-7(1)	Store parameter 
*                       Jump to output
 79:    LDA  1,-5(1)	Load address of new frame 
 80:    LDA  3,1(7)	Return address in ac 
 81:    LDA  7,-76(7)	CALL output
 82:    LDA  3,0(2)	Save the result in ac 
*                       End call to output
* END COMPOUND
* Add standard closing in case there is no return statement
 83:    LDC  2,0(6)	Set return value to 0 
 84:     LD  3,-1(1)	Load return address 
 85:     LD  1,0(1)	Adjust fp 
 86:    LDA  7,0(3)	Return 
* END FUNCTION fred
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION main
 87:     ST  3,-1(1)	Store return address. 
* COMPOUND
 88:    LDC  3,10(6)	load size of array a
 89:     ST  3,-4(1)	save size of array a
* Compound Body
* EXPRESSION
*                       Begin call to  fred
 90:     ST  1,-15(1)	Store old fp in ghost frame 
*                       Load param 1
 91:     LD  3,-2(1)	Load variable x
 92:     ST  3,-17(1)	Store parameter 
*                       Load param 2
 93:     LD  3,-3(1)	Load variable y
 94:     ST  3,-18(1)	Store parameter 
*                       Load param 3
 95:    LDA  3,-5(1)	Load address of base of array a
 96:     ST  3,-19(1)	Store parameter 
*                       Jump to fred
 97:    LDA  1,-15(1)	Load address of new frame 
 98:    LDA  3,1(7)	Return address in ac 
 99:    LDA  7,-58(7)	CALL fred
100:    LDA  3,0(2)	Save the result in ac 
*                       End call to fred
* END COMPOUND
* Add standard closing in case there is no return statement
101:    LDC  2,0(6)	Set return value to 0 
102:     LD  3,-1(1)	Load return address 
103:     LD  1,0(1)	Adjust fp 
104:    LDA  7,0(3)	Return 
* END FUNCTION main
  0:    LDA  7,104(7)	Jump to init [backpatch] 
* INIT
105:     LD  0,0(0)	Set the global pointer 
106:    LDA  1,0(0)	set first frame at end of globals 
107:     ST  1,0(1)	store old fp (point to self) 
* INIT GLOBALS AND STATICS
* END INIT GLOBALS AND STATICS
108:    LDA  3,1(7)	Return address in ac 
109:    LDA  7,-23(7)	Jump to main 
110:   HALT  0,0,0	DONE! 
* END INIT
