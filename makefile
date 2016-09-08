BIN=c-
LIB=-ll

TOK=scanType
TESTD=testDataA1
TESTF=scannerTest
OUT=out
TMP=tmp

DIFF=vimdiff 

OSXLIB=LIB=-ll
NIXLIB=LIB=

SUBT=submission.tar
TAR=tar -cvf
UNTAR=tar -xvf

ME=boss
ASSN=1
ASS=CS445 F16 Assignment $(ASSN)
FILE=`pwd`/$(TMP)/$(SUBT)
HOST=http://ec2-52-89-93-46.us-west-2.compute.amazonaws.com
SUBURL=$(HOST)/cgi-bin/fileCapture.py
SUBRESULT=result.html
EMAIL=open https://outlook.office.com/owa/?realm=vandals.uidaho.edu&path=/mail/inbox

all: compile

clean:
	- rm -rf lex.yy.c $(BIN) $(BIN).tab.c $(BIN).tab.h $(BIN).output $(SUBT) $(TMP)

flex:
	flex $(BIN).l

bison: 
	bison -v -t -d $(BIN).y

compile: clean flex bison
	g++ $(BIN).tab.c lex.yy.c $(LIB) -o $(BIN)

test:
	./$(BIN) test.c-

outdir:
	- mkdir out

comp: compile outdir
	./$(BIN) $(TESTD)/$(TESTF).c- > $(OUT)/$(TESTF).out
	$(DIFF) $(OUT)/$(TESTF).out $(TESTD)/$(TESTF).out 

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
	cat makefile | sed 's/$(OSXLIB)/$(NIXLIB)/g' > $(TMP)/makefile 
	cd tmp && $(TAR) $(SUBT) $(BIN).l $(BIN).y makefile $(TOK).h
	curl -F "student=$(ME)" -F "assignment=$(ASS)" -F "submittedfile=@$(FILE)" $(SUBURL) > $(TMP)/$(SUBRESULT) 
	$(EMAIL)
	open $(TMP)/$(SUBRESULT)
	echo "Result timestamp is: `cat $(TMP)/$(SUBRESULT) | grep -o '"[0-9]\+"'`."
