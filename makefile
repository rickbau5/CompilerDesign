BIN=c-
ROOT:=$(shell pwd)

TMP=tmp

SUBT=submission.tar
TAR=tar -cvf
UNTAR=tar -xvf

ME=boss
ASSN=4
FILE=$(ROOT)/$(TMP)/$(SUBT)
SUBRESULT=result.html

CFLAGS=-O3 -Wall
DFLAGS=-g -Wall

FLEX=$(BIN).l
FFLAGS=
BSON=$(BIN).y
BFLAGS=-v -t -d
INTER=$(BIN).tab.c lex.yy.c
SRCS=printtree.cpp semantic.cpp symbolTable.cpp yyerror.cpp
COMP=$(SRCS) -x c++ $(INTER) 
HEADERS=*.h
MAINSRC=main.cpp
TESTSRC=tests.cpp
PACKAGE=$(FLEX) $(BSON) $(SRCS) $(HEADERS) $(MAINSRC) makefile

all: compile

clean:
	@- rm -rf $(BIN) $(BIN).output $(BIN).tab.h tests tests.dSYM testing/*.out $(INTER) $(TMP) $(BIN).dSYM test.out

flex:
	flex $(FFLAGS) $(FLEX)

bison: 
	bison $(BFLAGS) $(BSON)

common_deps: flex bison

compile: clean common_deps
	g++ $(CFLAGS) $(COMP) $(MAINSRC) -o $(BIN)

debug: clean common_deps
	g++ $(DFLAGS) $(COMP) $(MAINSRC) -o $(BIN)

test:
	@./$(BIN) test.c-

tests: clean common_deps
	g++ -g $(COMP) $(TESTSRC) -o tests
	./tests
	scripts/compare.sh testing

tmp:
	- mkdir $(TMP)

prep-tar: clean tmp
	@ cp -r $(PACKAGE) $(TMP)
	@ cd $(TMP) && $(TAR) $(SUBT) $(PACKAGE) 

test-tar:
	@cd $(TMP); \
		mkdir $(TMP); \
		$(UNTAR) $(SUBT) -C $(TMP); \
		cd $(TMP); \
		make

wormulon: prep-tar
	scp $(TMP)/$(SUBT) boss2849@wormulon.cs.uidaho.edu:/home/boss2849/CS445/$(SUBT)

submit: prep-tar test-tar
	curlsubmit 445 $(ASSN) $(FILE) > $(TMP)/$(SUBRESULT)
	@open $(TMP)/$(SUBRESULT)
	@echo "Result timestamp is: `cat $(TMP)/$(SUBRESULT) | grep -o '"[0-9]\+"'`."
