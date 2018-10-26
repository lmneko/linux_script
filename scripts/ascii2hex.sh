#!/bin/bash
#dump jixiangID ASCII to hex

echo  -e  "$1" | hexdump -C -s skip | cut -c9- | sed  's/|.*$//g;s/[ ]//g' | sed '{N;s/\n//g;s/[a-z]/\u&/g}' 



