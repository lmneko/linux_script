#!/bin/bash
#hex to ascii
echo "$1" | sed 's/\(..\)/\\\\x\1/g' | xargs echo -e
