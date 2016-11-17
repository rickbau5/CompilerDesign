#!/bin/bash
# ls testData/A5 | grep "syntaxerr-.*.c-" | sed 's/\(syntaxerr-.*\).c-/\1/' | awk '{ system("bash scripts/dootherdiff.sh "$1) }'

for f in testData/A6/*.c- ; do
    long=${f%.c-}
    ./c- -P $long.c- > test.out && diff test.out $long.out > /dev/null 
    echo $?: ${long##*-}
done
