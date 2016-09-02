BIN=c-
TOK=scanType.c
TESTD=testDataA1
TESTF=scannerTest
OUT=out

all: compile

clean:
	- rm lex.yy.c $(BIN) $(BIN).tab.c $(BIN).output

flex:
	flex $(BIN).l

bison: 
	bison -v -t -d $(BIN).y

compile: clean flex bison
	g++ $(BIN).tab.c lex.yy.c -ll -o c-

test:
	./$(BIN) test.c-

outdir:
	- mkdir out

comp: compile outdir
	./$(BIN) $(TESTD)/$(TESTF).c- > $(OUT)/$(TESTF).out
	vimdiff $(OUT)/$(TESTF).out $(TESTD)/$(TESTF).out 
