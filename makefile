all: compile

clean:
	- rm lex.yy.c c- c-.tab.c scanType.h

flex:
	flex c-.l

bison:
	bison --defines=scanType.h c-.y

compile: clean flex bison
	g++ c-.tab.c lex.yy.c -ll -o c-

test:
	./c- test.c-
