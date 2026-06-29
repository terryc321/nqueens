#!/bin/bash

for n in {33..50}; do
    echo "Running n=$n"
    dest="solutions/solution$n.txt"
    echo `date` >> $dest
    dune exec queen-ocaml "$n" | tee -a $dest
    echo `date` >> $dest
done







