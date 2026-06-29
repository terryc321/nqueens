#!/bin/bash

# -n8 size of board
# -m1 just one solution or one model only please
# -m-1 unlimited solutions
#~/src/Prover9/bin/mace4 -n8 -m1 -f queens.in | tee queens8.out
~/src/Prover9/bin/mace4 -n40 -m1 -f queens.in | tee queens40.out


