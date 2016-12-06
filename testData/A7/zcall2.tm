* C- compiler version C-F16
* Built: Nov 13, 2016
* Author: Robert B. Heckendorn
* File compiled:  zcall2.c-
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
* FUNCTION fib
 42:     ST  3,-1(1)	Store return address. 
* COMPOUND
* Compound Body
* IF
 43:     LD  3,-2(1)	Load variable x
 44:     ST  3,-3(1)	Save left side 
 45:    LDC  3,2(6)	Load integer constant 
 46:     LD  4,-3(1)	Load left into ac1 
 47:    TLE  3,4,3	Op <= 
* THEN
* RETURN
 49:    LDC  3,1(6)	Load integer constant 
 50:    LDA  2,0(3)	Copy result to rt register 
 51:     LD  3,-1(1)	Load return address 
 52:     LD  1,0(1)	Adjust fp 
 53:    LDA  7,0(3)	Return 
 48:    JZR  3,6(7)	Jump around the THEN if false [backpatch] 
* ELSE
* RETURN
*                       Begin call to  fib
 55:     ST  1,-3(1)	Store old fp in ghost frame 
*                       Load param 1
 56:     LD  3,-2(1)	Load variable x
 57:     ST  3,-5(1)	Save left side 
 58:    LDC  3,1(6)	Load integer constant 
 59:     LD  4,-5(1)	Load left into ac1 
 60:    SUB  3,4,3	Op - 
 61:     ST  3,-5(1)	Store parameter 
*                       Jump to fib
 62:    LDA  1,-3(1)	Load address of new frame 
 63:    LDA  3,1(7)	Return address in ac 
 64:    LDA  7,-23(7)	CALL fib
 65:    LDA  3,0(2)	Save the result in ac 
*                       End call to fib
 66:     ST  3,-3(1)	Save left side 
*                       Begin call to  fib
 67:     ST  1,-4(1)	Store old fp in ghost frame 
*                       Load param 1
 68:     LD  3,-2(1)	Load variable x
 69:     ST  3,-6(1)	Save left side 
 70:    LDC  3,2(6)	Load integer constant 
 71:     LD  4,-6(1)	Load left into ac1 
 72:    SUB  3,4,3	Op - 
 73:     ST  3,-6(1)	Store parameter 
*                       Jump to fib
 74:    LDA  1,-4(1)	Load address of new frame 
 75:    LDA  3,1(7)	Return address in ac 
 76:    LDA  7,-35(7)	CALL fib
 77:    LDA  3,0(2)	Save the result in ac 
*                       End call to fib
 78:     LD  4,-3(1)	Load left into ac1 
 79:    ADD  3,4,3	Op + 
 80:    LDA  2,0(3)	Copy result to rt register 
 81:     LD  3,-1(1)	Load return address 
 82:     LD  1,0(1)	Adjust fp 
 83:    LDA  7,0(3)	Return 
 54:    LDA  7,29(7)	Jump around the ELSE [backpatch] 
* ENDIF
* END COMPOUND
* Add standard closing in case there is no return statement
 84:    LDC  2,0(6)	Set return value to 0 
 85:     LD  3,-1(1)	Load return address 
 86:     LD  1,0(1)	Adjust fp 
 87:    LDA  7,0(3)	Return 
* END FUNCTION fib
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION dog
 88:     ST  3,-1(1)	Store return address. 
* COMPOUND
* Compound Body
* RETURN
*                       Begin call to  fib
 89:     ST  1,-3(1)	Store old fp in ghost frame 
*                       Load param 1
 90:     LD  3,-2(1)	Load variable x
 91:     ST  3,-5(1)	Store parameter 
*                       Jump to fib
 92:    LDA  1,-3(1)	Load address of new frame 
 93:    LDA  3,1(7)	Return address in ac 
 94:    LDA  7,-53(7)	CALL fib
 95:    LDA  3,0(2)	Save the result in ac 
*                       End call to fib
 96:    LDA  2,0(3)	Copy result to rt register 
 97:     LD  3,-1(1)	Load return address 
 98:     LD  1,0(1)	Adjust fp 
 99:    LDA  7,0(3)	Return 
* END COMPOUND
* Add standard closing in case there is no return statement
100:    LDC  2,0(6)	Set return value to 0 
101:     LD  3,-1(1)	Load return address 
102:     LD  1,0(1)	Adjust fp 
103:    LDA  7,0(3)	Return 
* END FUNCTION dog
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION main
104:     ST  3,-1(1)	Store return address. 
* COMPOUND
* Compound Body
* EXPRESSION
*                       Begin call to  output
105:     ST  1,-2(1)	Store old fp in ghost frame 
*                       Load param 1
*                       Begin call to  fib
106:     ST  1,-4(1)	Store old fp in ghost frame 
*                       Load param 1
107:    LDC  3,1(6)	Load integer constant 
108:     ST  3,-6(1)	Store parameter 
*                       Jump to fib
109:    LDA  1,-4(1)	Load address of new frame 
110:    LDA  3,1(7)	Return address in ac 
111:    LDA  7,-70(7)	CALL fib
112:    LDA  3,0(2)	Save the result in ac 
*                       End call to fib
113:     ST  3,-4(1)	Store parameter 
*                       Jump to output
114:    LDA  1,-2(1)	Load address of new frame 
115:    LDA  3,1(7)	Return address in ac 
116:    LDA  7,-111(7)	CALL output
117:    LDA  3,0(2)	Save the result in ac 
*                       End call to output
* EXPRESSION
*                       Begin call to  output
118:     ST  1,-2(1)	Store old fp in ghost frame 
*                       Load param 1
*                       Begin call to  fib
119:     ST  1,-4(1)	Store old fp in ghost frame 
*                       Load param 1
120:    LDC  3,2(6)	Load integer constant 
121:     ST  3,-6(1)	Store parameter 
*                       Jump to fib
122:    LDA  1,-4(1)	Load address of new frame 
123:    LDA  3,1(7)	Return address in ac 
124:    LDA  7,-83(7)	CALL fib
125:    LDA  3,0(2)	Save the result in ac 
*                       End call to fib
126:     ST  3,-4(1)	Store parameter 
*                       Jump to output
127:    LDA  1,-2(1)	Load address of new frame 
128:    LDA  3,1(7)	Return address in ac 
129:    LDA  7,-124(7)	CALL output
130:    LDA  3,0(2)	Save the result in ac 
*                       End call to output
* EXPRESSION
*                       Begin call to  output
131:     ST  1,-2(1)	Store old fp in ghost frame 
*                       Load param 1
*                       Begin call to  fib
132:     ST  1,-4(1)	Store old fp in ghost frame 
*                       Load param 1
133:    LDC  3,3(6)	Load integer constant 
134:     ST  3,-6(1)	Store parameter 
*                       Jump to fib
135:    LDA  1,-4(1)	Load address of new frame 
136:    LDA  3,1(7)	Return address in ac 
137:    LDA  7,-96(7)	CALL fib
138:    LDA  3,0(2)	Save the result in ac 
*                       End call to fib
139:     ST  3,-4(1)	Store parameter 
*                       Jump to output
140:    LDA  1,-2(1)	Load address of new frame 
141:    LDA  3,1(7)	Return address in ac 
142:    LDA  7,-137(7)	CALL output
143:    LDA  3,0(2)	Save the result in ac 
*                       End call to output
* EXPRESSION
*                       Begin call to  output
144:     ST  1,-2(1)	Store old fp in ghost frame 
*                       Load param 1
*                       Begin call to  fib
145:     ST  1,-4(1)	Store old fp in ghost frame 
*                       Load param 1
146:    LDC  3,4(6)	Load integer constant 
147:     ST  3,-6(1)	Store parameter 
*                       Jump to fib
148:    LDA  1,-4(1)	Load address of new frame 
149:    LDA  3,1(7)	Return address in ac 
150:    LDA  7,-109(7)	CALL fib
151:    LDA  3,0(2)	Save the result in ac 
*                       End call to fib
152:     ST  3,-4(1)	Store parameter 
*                       Jump to output
153:    LDA  1,-2(1)	Load address of new frame 
154:    LDA  3,1(7)	Return address in ac 
155:    LDA  7,-150(7)	CALL output
156:    LDA  3,0(2)	Save the result in ac 
*                       End call to output
* EXPRESSION
*                       Begin call to  output
157:     ST  1,-2(1)	Store old fp in ghost frame 
*                       Load param 1
*                       Begin call to  fib
158:     ST  1,-4(1)	Store old fp in ghost frame 
*                       Load param 1
159:    LDC  3,5(6)	Load integer constant 
160:     ST  3,-6(1)	Store parameter 
*                       Jump to fib
161:    LDA  1,-4(1)	Load address of new frame 
162:    LDA  3,1(7)	Return address in ac 
163:    LDA  7,-122(7)	CALL fib
164:    LDA  3,0(2)	Save the result in ac 
*                       End call to fib
165:     ST  3,-4(1)	Store parameter 
*                       Jump to output
166:    LDA  1,-2(1)	Load address of new frame 
167:    LDA  3,1(7)	Return address in ac 
168:    LDA  7,-163(7)	CALL output
169:    LDA  3,0(2)	Save the result in ac 
*                       End call to output
* EXPRESSION
*                       Begin call to  output
170:     ST  1,-2(1)	Store old fp in ghost frame 
*                       Load param 1
*                       Begin call to  fib
171:     ST  1,-4(1)	Store old fp in ghost frame 
*                       Load param 1
172:    LDC  3,6(6)	Load integer constant 
173:     ST  3,-6(1)	Store parameter 
*                       Jump to fib
174:    LDA  1,-4(1)	Load address of new frame 
175:    LDA  3,1(7)	Return address in ac 
176:    LDA  7,-135(7)	CALL fib
177:    LDA  3,0(2)	Save the result in ac 
*                       End call to fib
178:     ST  3,-4(1)	Store parameter 
*                       Jump to output
179:    LDA  1,-2(1)	Load address of new frame 
180:    LDA  3,1(7)	Return address in ac 
181:    LDA  7,-176(7)	CALL output
182:    LDA  3,0(2)	Save the result in ac 
*                       End call to output
* EXPRESSION
*                       Begin call to  output
183:     ST  1,-2(1)	Store old fp in ghost frame 
*                       Load param 1
*                       Begin call to  fib
184:     ST  1,-4(1)	Store old fp in ghost frame 
*                       Load param 1
185:    LDC  3,7(6)	Load integer constant 
186:     ST  3,-6(1)	Store parameter 
*                       Jump to fib
187:    LDA  1,-4(1)	Load address of new frame 
188:    LDA  3,1(7)	Return address in ac 
189:    LDA  7,-148(7)	CALL fib
190:    LDA  3,0(2)	Save the result in ac 
*                       End call to fib
191:     ST  3,-4(1)	Store parameter 
*                       Jump to output
192:    LDA  1,-2(1)	Load address of new frame 
193:    LDA  3,1(7)	Return address in ac 
194:    LDA  7,-189(7)	CALL output
195:    LDA  3,0(2)	Save the result in ac 
*                       End call to output
* EXPRESSION
*                       Begin call to  outnl
196:     ST  1,-2(1)	Store old fp in ghost frame 
*                       Jump to outnl
197:    LDA  1,-2(1)	Load address of new frame 
198:    LDA  3,1(7)	Return address in ac 
199:    LDA  7,-163(7)	CALL outnl
200:    LDA  3,0(2)	Save the result in ac 
*                       End call to outnl
* END COMPOUND
* Add standard closing in case there is no return statement
201:    LDC  2,0(6)	Set return value to 0 
202:     LD  3,-1(1)	Load return address 
203:     LD  1,0(1)	Adjust fp 
204:    LDA  7,0(3)	Return 
* END FUNCTION main
  0:    LDA  7,204(7)	Jump to init [backpatch] 
* INIT
205:     LD  0,0(0)	Set the global pointer 
206:    LDA  1,0(0)	set first frame at end of globals 
207:     ST  1,0(1)	store old fp (point to self) 
* INIT GLOBALS AND STATICS
* END INIT GLOBALS AND STATICS
208:    LDA  3,1(7)	Return address in ac 
209:    LDA  7,-106(7)	Jump to main 
210:   HALT  0,0,0	DONE! 
* END INIT
