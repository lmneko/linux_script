#!/bin/bash

for (( i = 1; i <=8; i++ ))
do
	for (( j = 1; j <= 8; j++ ))
	do
		total=$(( $i + $j ))
		tmp=$(( $total % 2 ))
		if [ $tmp -eq 0 ];
		then
			echo -e -n "\e[1;5;41m  "
		else
			echo -e -n "\e[1;5;44m  "
		fi
	done
	echo -e "\e[0m"
done
