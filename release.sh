#!/bin/sh
set -x
dmd -O -m64 snip.d
rm *.o
