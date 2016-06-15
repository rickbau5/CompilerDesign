all: compile

compile: flex bison
	g++ cmin.tab.c lex.yy.c -lfl -o cmin

flex: 
	flex cmin.l

bison:
	bison -d cmin.y

clean:
	- rm lex.yy.c cmin cmin.tab.c cmin.tab.h

files:
	- rm everything04.txt scannerTestB.txt scannerCCode.txt

dir:
	- mkdir out

test1: files compile dir
	cat testDataA1/everything04.c- | ./cmin > out/everything04.txt
	diff --text out/everything04.txt testDataA1/everything04.out | less
	cat testDataA1/scannerTestB.c- | ./cmin > out/scannerTestB.txt
	diff --text out/scannerTestB.txt testDataA1/scannerTestB.out | less
	cat testDataA1/scannerCCode.c- | ./cmin > out/scannerCCode.txt
	diff --text out/scannerCCode.txt testDataA1/scannerCCode.out | less

