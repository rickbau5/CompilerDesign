* C- compiler version C-F16
* Built: Nov 13, 2016
* Author: Robert B. Heckendorn
* File compiled:  zcall3.c-
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
* FUNCTION ant
 42:     ST  3,-1(1)	Store return address. 
* RETURN
 43:    LDC  3,666(6)	Load integer constant 
 44:     ST  3,-3(1)	Save left side 
 45:     LD  3,-2(1)	Load variable a
 46:     LD  4,-3(1)	Load left into ac1 
 47:    MUL  3,4,3	Op * 
 48:    LDA  2,0(3)	Copy result to rt register 
 49:     LD  3,-1(1)	Load return address 
 50:     LD  1,0(1)	Adjust fp 
 51:    LDA  7,0(3)	Return 
* Add standard closing in case there is no return statement
 52:    LDC  2,0(6)	Set return value to 0 
 53:     LD  3,-1(1)	Load return address 
 54:     LD  1,0(1)	Adjust fp 
 55:    LDA  7,0(3)	Return 
* END FUNCTION ant
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION bat
 56:     ST  3,-1(1)	Store return address. 
* COMPOUND
* Compound Body
* RETURN
 57:    LDC  3,666(6)	Load integer constant 
 58:     ST  3,-3(1)	Save left side 
 59:     LD  3,-2(1)	Load variable b
 60:     LD  4,-3(1)	Load left into ac1 
 61:    MUL  3,4,3	Op * 
 62:    LDA  2,0(3)	Copy result to rt register 
 63:     LD  3,-1(1)	Load return address 
 64:     LD  1,0(1)	Adjust fp 
 65:    LDA  7,0(3)	Return 
* END COMPOUND
* Add standard closing in case there is no return statement
 66:    LDC  2,0(6)	Set return value to 0 
 67:     LD  3,-1(1)	Load return address 
 68:     LD  1,0(1)	Adjust fp 
 69:    LDA  7,0(3)	Return 
* END FUNCTION bat
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION cow
 70:     ST  3,-1(1)	Store return address. 
* COMPOUND
* Compound Body
* RETURN
 71:    LDC  3,666(6)	Load integer constant 
 72:     ST  3,-4(1)	Save left side 
 73:     LD  3,-2(1)	Load variable c
 74:     LD  4,-4(1)	Load left into ac1 
 75:    MUL  3,4,3	Op * 
 76:    LDA  2,0(3)	Copy result to rt register 
 77:     LD  3,-1(1)	Load return address 
 78:     LD  1,0(1)	Adjust fp 
 79:    LDA  7,0(3)	Return 
* END COMPOUND
* Add standard closing in case there is no return statement
 80:    LDC  2,0(6)	Set return value to 0 
 81:     LD  3,-1(1)	Load return address 
 82:     LD  1,0(1)	Adjust fp 
 83:    LDA  7,0(3)	Return 
* END FUNCTION cow
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION dog
 84:     ST  3,-1(1)	Store return address. 
* COMPOUND
* Compound Body
* COMPOUND
* Compound Body
* RETURN
 85:    LDC  3,666(6)	Load integer constant 
 86:     ST  3,-5(1)	Save left side 
 87:     LD  3,-2(1)	Load variable d
 88:     LD  4,-5(1)	Load left into ac1 
 89:    MUL  3,4,3	Op * 
 90:    LDA  2,0(3)	Copy result to rt register 
 91:     LD  3,-1(1)	Load return address 
 92:     LD  1,0(1)	Adjust fp 
 93:    LDA  7,0(3)	Return 
* END COMPOUND
* END COMPOUND
* Add standard closing in case there is no return statement
 94:    LDC  2,0(6)	Set return value to 0 
 95:     LD  3,-1(1)	Load return address 
 96:     LD  1,0(1)	Adjust fp 
 97:    LDA  7,0(3)	Return 
* END FUNCTION dog
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION main
 98:     ST  3,-1(1)	Store return address. 
* COMPOUND
* Compound Body
* EXPRESSION
*                       Begin call to  ant
 99:     ST  1,-2(1)	Store old fp in ghost frame 
*                       Load param 1
100:    LDC  3,111(6)	Load integer constant 
101:     ST  3,-4(1)	Store parameter 
*                       Jump to ant
102:    LDA  1,-2(1)	Load address of new frame 
103:    LDA  3,1(7)	Return address in ac 
104:    LDA  7,-63(7)	CALL ant
105:    LDA  3,0(2)	Save the result in ac 
*                       End call to ant
* EXPRESSION
*                       Begin call to  bat
106:     ST  1,-2(1)	Store old fp in ghost frame 
*                       Load param 1
107:    LDC  3,222(6)	Load integer constant 
108:     ST  3,-4(1)	Store parameter 
*                       Jump to bat
109:    LDA  1,-2(1)	Load address of new frame 
110:    LDA  3,1(7)	Return address in ac 
111:    LDA  7,-56(7)	CALL bat
112:    LDA  3,0(2)	Save the result in ac 
*                       End call to bat
* EXPRESSION
*                       Begin call to  cow
113:     ST  1,-2(1)	Store old fp in ghost frame 
*                       Load param 1
114:    LDC  3,333(6)	Load integer constant 
115:     ST  3,-4(1)	Store parameter 
*                       Jump to cow
116:    LDA  1,-2(1)	Load address of new frame 
117:    LDA  3,1(7)	Return address in ac 
118:    LDA  7,-49(7)	CALL cow
119:    LDA  3,0(2)	Save the result in ac 
*                       End call to cow
* EXPRESSION
*                       Begin call to  dog
120:     ST  1,-2(1)	Store old fp in ghost frame 
*                       Load param 1
121:    LDC  3,444(6)	Load integer constant 
122:     ST  3,-4(1)	Store parameter 
*                       Jump to dog
123:    LDA  1,-2(1)	Load address of new frame 
124:    LDA  3,1(7)	Return address in ac 
125:    LDA  7,-42(7)	CALL dog
126:    LDA  3,0(2)	Save the result in ac 
*                       End call to dog
* END COMPOUND
* Add standard closing in case there is no return statement
127:    LDC  2,0(6)	Set return value to 0 
128:     LD  3,-1(1)	Load return address 
129:     LD  1,0(1)	Adjust fp 
130:    LDA  7,0(3)	Return 
* END FUNCTION main
  0:    LDA  7,130(7)	Jump to init [backpatch] 
* INIT
131:     LD  0,0(0)	Set the global pointer 
132:    LDA  1,0(0)	set first frame at end of globals 
133:     ST  1,0(1)	store old fp (point to self) 
* INIT GLOBALS AND STATICS
* END INIT GLOBALS AND STATICS
134:    LDA  3,1(7)	Return address in ac 
135:    LDA  7,-38(7)	Jump to main 
136:   HALT  0,0,0	DONE! 
* END INIT
