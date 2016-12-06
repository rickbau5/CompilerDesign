* C- compiler version C-F16
* Built: Nov 13, 2016
* Author: Robert B. Heckendorn
* File compiled:  zcontrol.c-
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
 43:    LDC  3,1(6)	Load Boolean constant 
 44:     ST  3,-2(1)	Store variable x
* EXPRESSION
 45:    LDC  3,0(6)	Load Boolean constant 
 46:     ST  3,-3(1)	Store variable y
* IF
 47:     LD  3,-2(1)	Load variable x
* THEN
* EXPRESSION
 49:    LDC  3,111(6)	Load integer constant 
 48:    JZR  3,1(7)	Jump around the THEN if false [backpatch] 
* ENDIF
* IF
 50:     LD  3,-3(1)	Load variable y
* THEN
* EXPRESSION
 52:    LDC  3,222(6)	Load integer constant 
 51:    JZR  3,2(7)	Jump around the THEN if false [backpatch] 
* ELSE
* EXPRESSION
 54:    LDC  3,333(6)	Load integer constant 
 53:    LDA  7,1(7)	Jump around the ELSE [backpatch] 
* ENDIF
* IF
 55:     LD  3,-2(1)	Load variable x
* THEN
* IF
 57:     LD  3,-3(1)	Load variable y
* THEN
* EXPRESSION
 59:    LDC  3,444(6)	Load integer constant 
 58:    JZR  3,2(7)	Jump around the THEN if false [backpatch] 
* ELSE
* EXPRESSION
 61:    LDC  3,555(6)	Load integer constant 
 60:    LDA  7,1(7)	Jump around the ELSE [backpatch] 
* ENDIF
 56:    JZR  3,5(7)	Jump around the THEN if false [backpatch] 
* ENDIF
* WHILE
 62:     LD  3,-2(1)	Load variable x
 63:    JNZ  3,1(7)	Jump to while part 
* DO
* EXPRESSION
 65:    LDC  3,666(6)	Load integer constant 
 66:    LDA  7,-5(7)	go to beginning of loop 
 64:    LDA  7,2(7)	Jump past loop [backpatch] 
* ENDWHILE
* WHILE
 67:     LD  3,-3(1)	Load variable y
 68:    JNZ  3,1(7)	Jump to while part 
* DO
* COMPOUND
* Compound Body
* EXPRESSION
 70:    LDC  3,777(6)	Load integer constant 
* BREAK
 71:    LDA  7,-3(7)	break 
* EXPRESSION
 72:    LDC  3,888(6)	Load integer constant 
* BREAK
 73:    LDA  7,-5(7)	break 
* EXPRESSION
 74:    LDC  3,999(6)	Load integer constant 
* END COMPOUND
 75:    LDA  7,-9(7)	go to beginning of loop 
 69:    LDA  7,6(7)	Jump past loop [backpatch] 
* ENDWHILE
* WHILE
 76:     LD  3,-2(1)	Load variable x
 77:    JNZ  3,1(7)	Jump to while part 
* DO
* COMPOUND
* Compound Body
* EXPRESSION
 79:    LDC  3,111(6)	Load integer constant 
* BREAK
 80:    LDA  7,-3(7)	break 
* WHILE
 81:     LD  3,-3(1)	Load variable y
 82:    JNZ  3,1(7)	Jump to while part 
* DO
* COMPOUND
* Compound Body
* EXPRESSION
 84:    LDC  3,222(6)	Load integer constant 
* BREAK
 85:    LDA  7,-3(7)	break 
* EXPRESSION
 86:    LDC  3,333(6)	Load integer constant 
* END COMPOUND
 87:    LDA  7,-7(7)	go to beginning of loop 
 83:    LDA  7,4(7)	Jump past loop [backpatch] 
* ENDWHILE
* BREAK
 88:    LDA  7,-11(7)	break 
* EXPRESSION
 89:    LDC  3,444(6)	Load integer constant 
* END COMPOUND
 90:    LDA  7,-15(7)	go to beginning of loop 
 78:    LDA  7,12(7)	Jump past loop [backpatch] 
* ENDWHILE
* END COMPOUND
* Add standard closing in case there is no return statement
 91:    LDC  2,0(6)	Set return value to 0 
 92:     LD  3,-1(1)	Load return address 
 93:     LD  1,0(1)	Adjust fp 
 94:    LDA  7,0(3)	Return 
* END FUNCTION main
  0:    LDA  7,94(7)	Jump to init [backpatch] 
* INIT
 95:     LD  0,0(0)	Set the global pointer 
 96:    LDA  1,0(0)	set first frame at end of globals 
 97:     ST  1,0(1)	store old fp (point to self) 
* INIT GLOBALS AND STATICS
* END INIT GLOBALS AND STATICS
 98:    LDA  3,1(7)	Return address in ac 
 99:    LDA  7,-58(7)	Jump to main 
100:   HALT  0,0,0	DONE! 
* END INIT
