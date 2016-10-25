#!/bin/bash

for f in testData/A3/*.c- ; do
    n=${f%.*}
    handle=${n##*/}
    bash scripts/dodiff.sh $handle
done
