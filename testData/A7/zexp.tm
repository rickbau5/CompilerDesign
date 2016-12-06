* C- compiler version C-F16
* Built: Nov 13, 2016
* Author: Robert B. Heckendorn
* File compiled:  zexp.c-
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
* FUNCTION cat
 42:     ST  3,-1(1)	Store return address. 
* COMPOUND
* Compound Body
* EXPRESSION
 43:    LDC  3,333(6)	Load integer constant 
 44:     ST  3,-4(1)	Save left side 
 45:    LDC  3,444(6)	Load integer constant 
 46:     LD  4,-4(1)	Load left into ac1 
 47:    MUL  3,4,3	Op * 
* EXPRESSION
 48:     LD  3,-2(1)	load lhs variable x
 49:    LDA  3,1(3)	increment value of x
 50:     ST  3,-2(1)	Store variable x
* RETURN
 51:     LD  3,-2(1)	Load variable x
 52:    LDC  4,0(6)	Load 0 
 53:    SUB  3,4,3	Op unary - 
 54:    LDA  2,0(3)	Copy result to rt register 
 55:     LD  3,-1(1)	Load return address 
 56:     LD  1,0(1)	Adjust fp 
 57:    LDA  7,0(3)	Return 
* END COMPOUND
* Add standard closing in case there is no return statement
 58:    LDC  2,0(6)	Set return value to 0 
 59:     LD  3,-1(1)	Load return address 
 60:     LD  1,0(1)	Adjust fp 
 61:    LDA  7,0(3)	Return 
* END FUNCTION cat
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION main
 62:     ST  3,-1(1)	Store return address. 
* COMPOUND
* Compound Body
* EXPRESSION
 63:    LDC  3,333(6)	Load integer constant 
 64:     ST  3,-2(1)	Save left side 
 65:    LDC  3,444(6)	Load integer constant 
 66:     LD  4,-2(1)	Load left into ac1 
 67:    MUL  3,4,3	Op * 
* EXPRESSION
 68:    LDC  3,333(6)	Load integer constant 
 69:     ST  3,-2(1)	Save left side 
 70:    LDC  3,444(6)	Load integer constant 
 71:     LD  4,-2(1)	Load left into ac1 
 72:    MUL  3,4,3	Op * 
 73:     ST  3,-2(1)	Save left side 
 74:    LDC  3,555(6)	Load integer constant 
 75:     ST  3,-3(1)	Save left side 
 76:    LDC  3,666(6)	Load integer constant 
 77:     LD  4,-3(1)	Load left into ac1 
 78:    MUL  3,4,3	Op * 
 79:     LD  4,-2(1)	Load left into ac1 
 80:    ADD  3,4,3	Op + 
* EXPRESSION
 81:    LDC  3,333(6)	Load integer constant 
 82:     ST  3,-2(1)	Save left side 
 83:    LDC  3,444(6)	Load integer constant 
 84:     LD  4,-2(1)	Load left into ac1 
 85:    MUL  3,4,3	Op * 
 86:     ST  3,-2(1)	Save left side 
 87:    LDC  3,555(6)	Load integer constant 
 88:     ST  3,-3(1)	Save left side 
 89:    LDC  3,666(6)	Load integer constant 
 90:     LD  4,-3(1)	Load left into ac1 
 91:    MUL  3,4,3	Op * 
 92:     LD  4,-2(1)	Load left into ac1 
 93:    ADD  3,4,3	Op + 
 94:     ST  3,-2(1)	Save left side 
 95:    LDC  3,777(6)	Load integer constant 
 96:     ST  3,-3(1)	Save left side 
 97:    LDC  3,888(6)	Load integer constant 
 98:     LD  4,-3(1)	Load left into ac1 
 99:    MUL  3,4,3	Op * 
100:     LD  4,-2(1)	Load left into ac1 
101:    ADD  3,4,3	Op + 
* EXPRESSION
102:    LDC  3,111(6)	Load integer constant 
103:     ST  3,-2(1)	Save left side 
104:    LDC  3,222(6)	Load integer constant 
105:     ST  3,-3(1)	Save left side 
106:    LDC  3,333(6)	Load integer constant 
107:     ST  3,-4(1)	Save left side 
108:    LDC  3,444(6)	Load integer constant 
109:     LD  4,-4(1)	Load left into ac1 
110:    MUL  3,4,3	Op * 
111:     LD  4,-3(1)	Load left into ac1 
112:    ADD  3,4,3	Op + 
113:     LD  4,-2(1)	Load left into ac1 
114:    TLT  3,4,3	Op < 
* EXPRESSION
*                       Begin call to  cat
115:     ST  1,-2(1)	Store old fp in ghost frame 
*                       Load param 1
116:    LDC  3,111(6)	Load integer constant 
117:     ST  3,-4(1)	Store parameter 
*                       Load param 2
118:    LDC  3,222(6)	Load integer constant 
119:     ST  3,-5(1)	Store parameter 
*                       Jump to cat
120:    LDA  1,-2(1)	Load address of new frame 
121:    LDA  3,1(7)	Return address in ac 
122:    LDA  7,-81(7)	CALL cat
123:    LDA  3,0(2)	Save the result in ac 
*                       End call to cat
* EXPRESSION
124:    LDC  3,666(6)	Load integer constant 
125:     ST  3,-2(1)	Save left side 
*                       Begin call to  cat
126:     ST  1,-3(1)	Store old fp in ghost frame 
*                       Load param 1
127:    LDC  3,111(6)	Load integer constant 
128:     ST  3,-5(1)	Store parameter 
*                       Load param 2
129:    LDC  3,222(6)	Load integer constant 
130:     ST  3,-6(1)	Store parameter 
*                       Jump to cat
131:    LDA  1,-3(1)	Load address of new frame 
132:    LDA  3,1(7)	Return address in ac 
133:    LDA  7,-92(7)	CALL cat
134:    LDA  3,0(2)	Save the result in ac 
*                       End call to cat
135:     LD  4,-2(1)	Load left into ac1 
136:    ADD  3,4,3	Op + 
* END COMPOUND
* Add standard closing in case there is no return statement
137:    LDC  2,0(6)	Set return value to 0 
138:     LD  3,-1(1)	Load return address 
139:     LD  1,0(1)	Adjust fp 
140:    LDA  7,0(3)	Return 
* END FUNCTION main
  0:    LDA  7,140(7)	Jump to init [backpatch] 
* INIT
141:     LD  0,0(0)	Set the global pointer 
142:    LDA  1,0(0)	set first frame at end of globals 
143:     ST  1,0(1)	store old fp (point to self) 
* INIT GLOBALS AND STATICS
* END INIT GLOBALS AND STATICS
144:    LDA  3,1(7)	Return address in ac 
145:    LDA  7,-84(7)	Jump to main 
146:   HALT  0,0,0	DONE! 
* END INIT
