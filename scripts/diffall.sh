#!/bin/bash


for f in testData/A3/*.c- ; do
    n=${f%.*}
    echo "${n%/*}"
done
