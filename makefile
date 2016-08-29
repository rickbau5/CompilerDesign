all: compile

clean:
	- rm lex.yy.c c-

flex:
	flex c-.l

compile: clean flex
	g++ lex.yy.c -ll -o c-
