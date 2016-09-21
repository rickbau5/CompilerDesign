#!/bin/bash

FILES=testing/*.out

TESTS=0
ERRORS=0
echo ""
for f in $FILES ; do 
    ((TESTS++))
    DIFF=$(diff $f ${f/out/expected})
    TEST=${f#*/}
    TEST=${TEST%.*}
    if [ "$DIFF" == "" ] ; then
      echo "ok $TEST"
    else 
       echo "failed: $TEST"
       echo "output << >> expected"
       echo "$DIFF"
       ((ERRORS++))
    fi 
done

echo "Finished tests."
echo "$ERRORS/$TESTS errored."
