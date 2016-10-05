BIN=c-
ROOT:=$(shell pwd)

ASSN=2

TOK=scanType
TESTD=testData/A$(ASSN)
TESTF=init
OUT=out
TMP=tmp

DIFF=vimdiff 

SUBT=submission.tar
TAR=tar -cvf
UNTAR=tar -xvf

SRC=src

SRC_MAIN =$(ROOT)/$(SRC)/main
SRC_TEST =$(ROOT)/$(SRC)/test
SRC_ALL  =$(ROOT)/$(SRC)/all
OUT_DIR  =$(ROOT)/out
BUILD_DIR=$(ROOT)/build
TESTS_DIR=$(ROOT)/testing

SCRIPTS_DIR=$(ROOT)/scripts

ME=boss
ASS=CS445 F16 Assignment $(ASSN)
FILE=`pwd`/$(TMP)/$(SUBT)
HOST=http://ec2-52-89-93-46.us-west-2.compute.amazonaws.com
SUBURL=$(HOST)/cgi-bin/fileCapture.py
SUBRESULT=result.html
EMAIL=open https://outlook.office.com/owa/?realm=vandals.uidaho.edu&path=/mail/inbox

FLEX=$(BIN).l
BSON=$(BIN).y
INTER=$(BIN).tab.c lex.yy.c
SRCS=util.cpp symbolTable.cpp 
COMP=$(SRCS) $(INTER) 
HEADERS=*.h
MAINSRC=main.cpp
TESTSRC=tests.cpp
PACKAGE=$(FLEX) $(BSON) $(SRCS) $(HEADERS) $(MAINSRC) makefile

all: compile

clean:
	- rm -rf $(OUT_DIR) $(BUILD_DIR)

flex:
	cd $(BUILD_DIR) && flex $(FLEX)

bison: 
	cd $(BUILD_DIR) && bison -v -t -d $(BSON)

build_dir:
	- mkdir build

out_dir:
	- mkdir out

copy_all: build_dir
	@cp $(SRC_ALL)/* $(BUILD_DIR)

copy_main: build_dir
	@cp $(SRC_MAIN)/* $(BUILD_DIR)

copy_test: build_dir
	@cp $(SRC_TEST)/* $(BUILD_DIR)

common_deps: out_dir copy_all flex bison

compile_deps: common_deps copy_main

compile: clean compile_deps
	cd $(BUILD_DIR) && g++ $(COMP) $(MAINSRC) -o $(BIN)
	@mv $(BUILD_DIR)/$(BIN) $(OUT_DIR)/$(BIN)	
	@cp $(OUT_DIR)/$(BIN) $(ROOT)/$(BIN)

debug: clean compile_deps
	cd $(BUILD_DIR) && g++ -g $(COMP) $(MAINSRC) -o $(BIN)

test:
	@$(OUT_DIR)/$(BIN) $(ROOT)/test.c-

tests: clean common_deps copy_test
	@cd $(BUILD_DIR) && g++ -g $(COMP) $(TESTSRC) -o tests
	@mv $(BUILD_DIR)/tests $(OUT_DIR)/tests
	@cp -r $(TESTS_DIR) $(OUT_DIR) 
	@cd $(OUT_DIR); \
		./tests; \
		$(SCRIPTS_DIR)/compare.sh testing

outdir:
	- mkdir out

tar:
	$(TAR) $(SUBT) $(BIN).l $(BIN).y makefile $(TOK).h

untar:
	$(UNTAR) $(SUBT)

tmp:
	- mkdir $(TMP)

prep-tar: clean tmp
	@ cp -r src makefile tmp
	@ cd tmp && $(TAR) $(SUBT) src makefile 

test-tar:
	cd tmp; \
		$(UNTAR) $(SUBT) -C tmp; \
		cd tmp; \
		make

wormulon: prep-tar
	scp $(TMP)/$(SUBT) boss2849@wormulon.cs.uidaho.edu:/home/boss2849/CS445/$(SUBT)

submit: prep-tar test-tar
	curl -F "student=$(ME)" -F "assignment=$(ASS)" -F "submittedfile=@$(FILE)" $(SUBURL) > $(TMP)/$(SUBRESULT) 
	@open $(TMP)/$(SUBRESULT)
	echo "Result timestamp is: `cat $(TMP)/$(SUBRESULT) | grep -o '"[0-9]\+"'`."
