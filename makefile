BIN=c-

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
HEADERS=util.h symbolTable.h scanType.h $(BIN).h supgetopt.h
MAINSRC=main.cpp
TESTSRC=tests.cpp
PACKAGE=$(FLEX) $(BSON) $(SRCS) $(HEADERS) $(MAINSRC) makefile

all: compile

clean:
	- rm -rf $(BIN) $(INTER) $(BIN).tab.h $(BIN).output $(SUBT) $(TMP) testing/*.out *.dSYM tests

flex:
	flex $(FLEX)

bison: 
	bison -v -t -d $(BSON) 

compile: clean flex bison
	g++ $(COMP) $(MAINSRC) -o $(BIN)

debug: clean flex bison
	g++ -g $(COMP) $(MAINSRC) -o $(BIN)

test:
	./$(BIN) test.c-

tests: clean flex bison
	g++ -g $(COMP) $(TESTSRC) -o tests 
	./tests
	./compare.sh

outdir:
	- mkdir out

comp: compile outdir
	./$(BIN) test.c- > $(OUT)/test.out
	$(DIFF) $(OUT)/test.out $(TESTD)/small.out 

tar:
	$(TAR) $(SUBT) $(BIN).l $(BIN).y makefile $(TOK).h

untar:
	$(UNTAR) $(SUBT)

tmp:
	- mkdir $(TMP)

prep-tar: clean tmp
	cp $(PACKAGE) $(TMP)/
	cd tmp && $(TAR) $(SUBT) $(PACKAGE)

wormulon: prep-tar
	scp $(TMP)/$(SUBT) boss2849@wormulon.cs.uidaho.edu:/home/boss2849/CS445/$(SUBT)

submit: prep-tar
	cd tmp && $(TAR) $(SUBT) $(PACKAGE) 
	curl -F "student=$(ME)" -F "assignment=$(ASS)" -F "submittedfile=@$(FILE)" $(SUBURL) > $(TMP)/$(SUBRESULT) 
	open $(TMP)/$(SUBRESULT)
	echo "Result timestamp is: `cat $(TMP)/$(SUBRESULT) | grep -o '"[0-9]\+"'`."
