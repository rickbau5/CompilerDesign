#!/bin/bash

./c- -P testData/A4/$1.c- > test.out && vimdiff test.out testData/A4/$1.out
