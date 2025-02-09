#!/bin/sh
set -x
../snip --split text.txt OUT/
../snip --join OUT/ joined.txt
