#!/bin/bash

./c- -P testData/A3/$1.c- > test.out && vimdiff test.out testData/A3/$1.out
