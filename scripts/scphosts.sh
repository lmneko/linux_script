#!/bin/bash
#同步"/etc/hosts"文件至其他服务器
source ~/.profile
file="/etc/hosts"
user="root"
passwd="123456"
which expect || yum install -y expect || apt-get -y install expect || exit 1
echo '#!/usr/bin/expect

set timeout 60
set file   [lindex $argv 0]
set user   [lindex $argv 1]
set passwd [lindex $argv 2]
set ip     [lindex $argv 3]

spawn scp $file ${user}@${ip}:/etc
expect {
"Are you sure you want to continue connecting" {send "yes\r"; exp_continue}
"password:" {send "${passwd}\r"}
}
interact' > scpfile.exp
chmod 755 scpfile.exp
echo 
for  i in "$@"
do
	./scpfile.exp $file $user $passwd $i
done 
rm -f scpfile.exp