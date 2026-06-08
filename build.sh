#!/bin/bash

rm -f demo 
csc -O3 -o demo queen-array-one-solution.scm
time ./demo

