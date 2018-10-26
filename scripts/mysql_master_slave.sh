#!/bin/bash
#2018-06-20
#auto config mysql one master and many slavers
#by auther:xufeng


CONFIG="/etc/my.cnf"
SQL_MASTER_USER="root"
SQL_MASTER_PW=""
SQL_SLAVE_USER="slave"
SQL_SLAVE_PW="123456"
SQL_USER="root"
LOG_FILE=
LOG_POS=
SLAVE_IP="$@"
#The user name and password of slave_server 
SLAVE_USER="root"
SLAVE_PW="123456"


which expect || yum -y install expect
which ifconfig || yum -y install net-tools
MASTER_IP=`ifconfig|grep "broadcast"|awk '{print $2}'`

INS_MYSQL() {
	which mysqld || yum -y install mariadb mariadb-server mariadb-devel
	systemctl start mariadb
	systemctl stop firewalld && systemctl disable firewalld
	if [ "$?" -ne 0 ];then
		echo "Install MySQL error!"
		exit 1
	fi
}

CONFIG_MASTER() {
	INS_MYSQL
	cat>${CONFIG}<<EOF
[mysqld]
log-bin=mysql-bin
server-id=${MASTER_IP##*.}
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
symbolic-links=0
[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid
!includedir /etc/my.cnf.d
EOF
	systemctl restart mariadb
	for i in "${SLAVE_IP}"
	do
		mysql -e "grant replication slave on *.* to '${SQL_SLAVE_USER}'@'${i}' identified by '${SQL_SLAVE_PW}';flush privileges;"
	done
	LOG_FILE=`mysql -e "show master status\G"|grep File|awk -F' ' '{print $2}'`
	LOG_POS=`mysql -e "show master status\G"|grep Position|awk -F' ' '{print $2}'`
}

CREATE_EXP() {
echo '#!/usr/bin/expect

set timeout 60
set cmd    [lindex $argv 0]
set user   [lindex $argv 1]
set passwd [lindex $argv 2]
set ip     [lindex $argv 3]

spawn ssh ${user}@${ip} ${cmd}
expect {
"Are you sure you want to continue connecting" {send "yes\r"; exp_continue}
"password:" {send "${passwd}\r"}
}
interact' > sshcmd.exp
chmod 755 sshcmd.exp
echo '#!/usr/bin/expect

set timeout 60
set file   [lindex $argv 0]
set user   [lindex $argv 1]
set passwd [lindex $argv 2]
set ip     [lindex $argv 3]

spawn scp ${file} ${user}@${ip}:/etc 
expect {
"Are you sure you want to continue connecting" {send "yes\r"; exp_continue}
"password:" {send "${passwd}\r"}
}
interact' > scpcmd.exp
chmod 755 scpcmd.exp
}
	
CONFIG_SLAVE() {
	for i in "$SLAVE_IP"
	do
		expect sshcmd.exp "which mysqld || yum -y install mariadb mariadb-server;systemctl start mariadb && systemctl enable mariadb" ${SLAVE_USER} ${SLAVE_PW} $i
		expect scpcmd.exp ${CONFIG} ${SLAVE_USER} ${SLAVE_PW} $i
		expect sshcmd.exp "sed -i \"s/^server-id=*$/server-id=${i##*.}/\" ${CONFIG}" ${SLAVE_USER} ${SLAVE_PW} $i
		expect sshcmd.exp "mysql -e \"stop slave;change master to master_host='${MASTER_IP}',master_user='${SQL_SLAVE_USER}',master_password='${SQL_SLAVE_PW}',master_log_file='${LOG_FILE}',master_log_pos=${LOG_POS};slave start;\"" ${SLAVE_USER} ${SLAVE_PW} $i
		sleep 2
		SLAVE_RUN=`expect sshcmd.exp "mysql -e \"show slave status\G\"" ${SLAVE_USER} ${SLAVE_PW} $i | grep Running | grep -c Yes`
		if [ "$SLAVE_RUN" -eq "2" ];then
			echo "Config Host:${i} MySQL slave server successful!"
		else
			echo "Config Host:${i} MySQL slave server failed!"
		fi
	done
	
}
HELP() {
	echo -e "\033[32maAuto config one master and many slave MySQL server\033[0m"
	echo "Usage : $(basename "$0") slave_ip..."
	echo "example : $(basename "$0") 192.168.100.112 192.168.100.114"
}

if [ "$#" -eq "0" ];then
	HELP
	exit 1
fi

for i in $SLAVE_IP
do
	echo $i|grep -E "\<([0-9]{1,3}\.){3}([0-9]{1,3})\>"
	if [ "$?" -ne "0" ];then
		echo "invlid IP address!"
		HELP
		exit 1
	fi
done

CONFIG_MASTER
CREATE_EXP
CONFIG_SLAVE $@
