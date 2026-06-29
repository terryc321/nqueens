#!/bin/bash

set -e

dune build && dune exec queen-ocaml

