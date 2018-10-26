#!/bin/bash
#
#hitoko 一言
#ADDR='https://v1.hitokoto.cn'
#text=`curl https://v1.hitokoto.cn/?c=d | grep -E "hitokoto|from" | sed 's/[,]//g;s/["]//g;s/[:]//g' | awk '{print $2}'`
#/mnt/c/Windows/System32/msg.exe sand $text
addr='https://api.lwl12.com/hitokoto/v1'
text=`curl https://api.lwl12.com/hitokoto/v1`
echo "$text" >> hitokoto_save.txt 
