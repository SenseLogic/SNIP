#!/bin/sh
set -x
dmd -m64 snip.d
rm *.o
