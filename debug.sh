#!/bin/sh
set -x
dmd -debug -g -gf -gs -m64 snip.d
rm *.o
