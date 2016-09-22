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

all: compile

clean:
	- rm -rf lex.yy.c $(BIN) $(BIN).tab.c $(BIN).tab.h $(BIN).output $(SUBT) $(TMP) testing/*.out *.dSYM tests

flex:
	flex $(BIN).l

bison: 
	bison -v -t -d $(BIN).y

compile: clean flex bison
	g++ util.cpp $(BIN).tab.c lex.yy.c main.cpp -o $(BIN)

debug: clean flex bison
	g++ -g util.cpp $(BIN).tab.c lex.yy.c main.cpp -o $(BIN)

test:
	./$(BIN) test.c-

tests: clean flex bison
	g++ -g util.cpp tests.cpp c-.tab.c lex.yy.c -o tests 
	./tests
	./compare.sh

outdir:
	- mkdir out

comp-old: compile outdir
	./$(BIN) $(TESTD)/$(TESTF).c- > $(OUT)/$(TESTF).out
	$(DIFF) $(OUT)/$(TESTF).out $(TESTD)/$(TESTF).out 

comp: compile outdir
	./$(BIN) test.c- > $(OUT)/test.out
	$(DIFF) $(OUT)/test.out $(TESTD)/small.out 

tar:
	$(TAR) $(SUBT) $(BIN).l $(BIN).y makefile $(TOK).h

untar:
	$(UNTAR) $(SUBT)

tmp:
	- mkdir $(TMP)

tar-test: tmp tar
	mv $(SUBT) $(TMP)
	cp -r $(TESTD) $(TMP)/$(TESTD)
	$(UNTAR) $(TMP)/$(SUBT) -C $(TMP)/
	cd $(TMP) && make comp

submit: clean tmp
	cp $(BIN).l $(BIN).y $(TOK).h $(TMP)/ 
	cp makefile $(TMP)/makefile
	cd tmp && $(TAR) $(SUBT) $(BIN).l $(BIN).y makefile $(TOK).h
	curl -F "student=$(ME)" -F "assignment=$(ASS)" -F "submittedfile=@$(FILE)" $(SUBURL) > $(TMP)/$(SUBRESULT) 
	$(EMAIL)
	open $(TMP)/$(SUBRESULT)
	echo "Result timestamp is: `cat $(TMP)/$(SUBRESULT) | grep -o '"[0-9]\+"'`."
