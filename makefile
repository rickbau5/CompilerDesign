BIN=c-
TOKS=scanType.h

all: compile

clean:
	- rm lex.yy.c c- $(BIN).tab.c $(TOKS) $(BIN).output 

flex:
	flex $(BIN).l

bison:
	bison -v -t --defines=$(TOKS) $(BIN).y

compile: clean flex bison
	g++ $(BIN).tab.c lex.yy.c -ll -o c-

test:
	./$(BIN) test.c-
