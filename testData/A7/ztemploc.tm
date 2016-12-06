* C- compiler version C-F16
* Built: Nov 13, 2016
* Author: Robert B. Heckendorn
* File compiled:  ztemploc.c-
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
* Compound Body
* EXPRESSION
 43:    LDC  3,111(6)	Load integer constant 
 44:     ST  3,-3(1)	Save left side 
 45:    LDC  3,222(6)	Load integer constant 
 46:     LD  4,-3(1)	Load left into ac1 
 47:    ADD  3,4,3	Op + 
* EXPRESSION
*                       Begin call to  main
 48:     ST  1,-3(1)	Store old fp in ghost frame 
*                       Jump to main
 49:    LDA  1,-3(1)	Load address of new frame 
 50:    LDA  3,1(7)	Return address in ac 
 51:    LDA  7,-10(7)	CALL main
 52:    LDA  3,0(2)	Save the result in ac 
*                       End call to main
* COMPOUND
* Compound Body
* EXPRESSION
 53:    LDC  3,333(6)	Load integer constant 
 54:     ST  3,-4(1)	Save left side 
 55:    LDC  3,444(6)	Load integer constant 
 56:     LD  4,-4(1)	Load left into ac1 
 57:    ADD  3,4,3	Op + 
* EXPRESSION
*                       Begin call to  main
 58:     ST  1,-4(1)	Store old fp in ghost frame 
*                       Jump to main
 59:    LDA  1,-4(1)	Load address of new frame 
 60:    LDA  3,1(7)	Return address in ac 
 61:    LDA  7,-20(7)	CALL main
 62:    LDA  3,0(2)	Save the result in ac 
*                       End call to main
* COMPOUND
* Compound Body
* EXPRESSION
 63:    LDC  3,555(6)	Load integer constant 
 64:     ST  3,-5(1)	Save left side 
 65:    LDC  3,666(6)	Load integer constant 
 66:     LD  4,-5(1)	Load left into ac1 
 67:    ADD  3,4,3	Op + 
* EXPRESSION
*                       Begin call to  main
 68:     ST  1,-5(1)	Store old fp in ghost frame 
*                       Jump to main
 69:    LDA  1,-5(1)	Load address of new frame 
 70:    LDA  3,1(7)	Return address in ac 
 71:    LDA  7,-30(7)	CALL main
 72:    LDA  3,0(2)	Save the result in ac 
*                       End call to main
* END COMPOUND
* EXPRESSION
 73:    LDC  3,777(6)	Load integer constant 
 74:     ST  3,-4(1)	Save left side 
 75:    LDC  3,888(6)	Load integer constant 
 76:     LD  4,-4(1)	Load left into ac1 
 77:    ADD  3,4,3	Op + 
* EXPRESSION
*                       Begin call to  main
 78:     ST  1,-4(1)	Store old fp in ghost frame 
*                       Jump to main
 79:    LDA  1,-4(1)	Load address of new frame 
 80:    LDA  3,1(7)	Return address in ac 
 81:    LDA  7,-40(7)	CALL main
 82:    LDA  3,0(2)	Save the result in ac 
*                       End call to main
* COMPOUND
* Compound Body
* EXPRESSION
 83:    LDC  3,999(6)	Load integer constant 
 84:     ST  3,-6(1)	Save left side 
 85:    LDC  3,111(6)	Load integer constant 
 86:     LD  4,-6(1)	Load left into ac1 
 87:    ADD  3,4,3	Op + 
* EXPRESSION
*                       Begin call to  main
 88:     ST  1,-6(1)	Store old fp in ghost frame 
*                       Jump to main
 89:    LDA  1,-6(1)	Load address of new frame 
 90:    LDA  3,1(7)	Return address in ac 
 91:    LDA  7,-50(7)	CALL main
 92:    LDA  3,0(2)	Save the result in ac 
*                       End call to main
* END COMPOUND
* EXPRESSION
 93:    LDC  3,222(6)	Load integer constant 
 94:     ST  3,-4(1)	Save left side 
 95:    LDC  3,333(6)	Load integer constant 
 96:     LD  4,-4(1)	Load left into ac1 
 97:    ADD  3,4,3	Op + 
* EXPRESSION
*                       Begin call to  main
 98:     ST  1,-4(1)	Store old fp in ghost frame 
*                       Jump to main
 99:    LDA  1,-4(1)	Load address of new frame 
100:    LDA  3,1(7)	Return address in ac 
101:    LDA  7,-60(7)	CALL main
102:    LDA  3,0(2)	Save the result in ac 
*                       End call to main
* END COMPOUND
* EXPRESSION
103:    LDC  3,444(6)	Load integer constant 
104:     ST  3,-3(1)	Save left side 
105:    LDC  3,555(6)	Load integer constant 
106:     LD  4,-3(1)	Load left into ac1 
107:    ADD  3,4,3	Op + 
* EXPRESSION
*                       Begin call to  main
108:     ST  1,-3(1)	Store old fp in ghost frame 
*                       Jump to main
109:    LDA  1,-3(1)	Load address of new frame 
110:    LDA  3,1(7)	Return address in ac 
111:    LDA  7,-70(7)	CALL main
112:    LDA  3,0(2)	Save the result in ac 
*                       End call to main
* END COMPOUND
* Add standard closing in case there is no return statement
113:    LDC  2,0(6)	Set return value to 0 
114:     LD  3,-1(1)	Load return address 
115:     LD  1,0(1)	Adjust fp 
116:    LDA  7,0(3)	Return 
* END FUNCTION main
  0:    LDA  7,116(7)	Jump to init [backpatch] 
* INIT
117:     LD  0,0(0)	Set the global pointer 
118:    LDA  1,-1(0)	set first frame at end of globals 
119:     ST  1,0(1)	store old fp (point to self) 
* INIT GLOBALS AND STATICS
* END INIT GLOBALS AND STATICS
120:    LDA  3,1(7)	Return address in ac 
121:    LDA  7,-80(7)	Jump to main 
122:   HALT  0,0,0	DONE! 
* END INIT
