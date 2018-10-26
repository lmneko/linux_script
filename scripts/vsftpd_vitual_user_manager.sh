#!/bin/bash
#2018年7月16日21:08:46
#manager vsftp virtual user
#auther: xufeng🌸✈
##############################

FTP_SYS_USER="ftpuser"
FTP_HOME="/home/${FTP_SYS_USER}"
FTP_CONF_DIR="/etc"
FTP_CONF_FILE="${FTP_CONF_DIR}/vsftpd.conf"
VUSER_CONF_DIR="${FTP_SYS_USER}/vsftp_user_conf"
VUSER_TXT="${FTP_CONF_DIR}/ftpuser.txt"
VUSER_DB="${FTP_CONF_DIR}/vsftpd_login.db"
PAM_FILE="/etc/pam.d/vsftpd"
VUSER_NAME=""
VUSER_PW="123456"
USE_SSL="YES"
BAK_DIR="/data/backup/`date +%Y%m%d`"
#trap '' SIGINT SIGQUIT
#set -o ignoreeof

if [ ! -d "$BAK_DIR" ];then
	mkdir -p $BAK_DIR
fi

 add_conf(){
	grep "$1" ${FTP_CONF_FILE}
	if [ "$?" -ne "0" ];then
		echo "$1" >> ${FTP_CONF_FILE}
	fi
	
}

 conf_vsftpd(){
	which vsftpd || yum -y install vsftpd > /dev/null 2>&1
	yum -y install pam* libdb-utils libdb* --skip-broken 
	useradd -s /sbin/nologin ${FTP_SYS_USER} 2>/dev/null
	if [ ! -f "${BAK_DIR}/${PAM_FILE##*/}" ];then
		cp ${PAM_FILE} ${BAK_DIR}
	fi
	echo "auth sufficient pam_userdb.so db=${VUSER_DB%.*}" > ${PAM_FILE}
	echo "account sufficient pam_userdb.so db=${VUSER_DB%.*}" >> ${PAM_FILE}
	if [ ! -f "${BAK_DIR}/${FTP_CONF_FILE##*/}" ];then
		cp ${FTP_CONF_FILE} $BAK_DIR
	fi
	add_conf "guest_enable=YES"
	add_conf "guest_username=ftpuser"
	add_conf "allow_writeable_chroot=YES"
	systemctl restart vsftpd || exit 1
}

 chk_user_ex(){
	if [ ! -f ${VUSER_TXT} ];then
		touch ${VUSER_TXT}
	fi
	FILE_USERNAME=(`sed -n 'p;N;!p' "${VUSER_TXT}"`)
	USER_ETC=(`cat /etc/passwd|awk -F: '{print $1}'`)
	for n in "${FILE_USERNAME[@]}"
	do
		if [ "$1" == "$n" ];then
			echo "The User:${1} has exist!"
			return 1
			break
		fi
	done
	for n in "${USER_ETC[@]}"
	do
		if [ "$1" == "$n" ];then
			echo "The User:${1} is system User!"
			return 2
			break
		fi
	done
	for n in "${VUSER_NAME[@]}"
	do
		if [ "$1" == "$n" ];then
			echo "The User:${1} has Inputed!"
			return 1
			break
		fi
	done
	echo "The User:${1} is not exist."
}

 input_name(){
	COUNT=0
	if [ "$1" == "del" ];then
		ACTION="Delete"
	fi
	while true
	do
		if [ "$1" != "file" ];then
			read -p "Please enter the ftp virtual username you need to ${ACTION:-Add}:" IN_VUSER
		fi
		if [ -z "$IN_VUSER" ];then
				echo "Null Input!"
				input_name  user
		fi 
		for i in "${IN_VUSER[@]}"
		do
			chk_user_ex $i
			if [ "$?" == "0" -o "$1" == "del" ];then
				VUSER_NAME[${COUNT}]=$i
				let COUNT+=1
			fi
		done
		case "$1" in
			file)
				return 0
				break
				;;
			del)
				return 1
				break
				;;
			*)
				read -p "Weather continue Input?[Y/N]" RES
				if [[ "$RES" =~ (y|yes|Y|Yes|YES) ]];then
					continue
				else
					break
				fi
				;;
		esac
	done
	unset IN_VUSER ACTION
}

 cre_vuser_conf() {
	if [ -n "$1" ];then
	    if [ ! -d ${VUSER_CONF_DIR} ];then
	        mkdir -p ${VUSER_CONF_DIR}
	    fi
	    if [ ! -d ${FTP_HOME}/$1 ];then
	        mkdir -p ${FTP_HOME}/$1
	    fi
	    chown -R ${FTP_SYS_USER}:${FTP_SYS_USER} ${FTP_HOME}
	    
	    cat>${VUSER_CONF_DIR}/${1}<<EOF
	    local_root=${FTP_HOME}/${1}
	    write_enable=YES
	    anon_world_readable_only=YES
	    anon_upload_enable=YES
	    anon_mkdir_rwrite=YES
	    anon_other_write_enable=YES
EOF
	else
		echo "User name is NULL!"
		return 1
	fi
}

 del_vuser_conf(){
	if [ -d "${VUSER_CONF_DIR}/${1}" ];then
		mv "${VUSER_CONF_DIR}/${1}" /tmp 2>>/dev/null
	fi
}

 add_vuser_name(){
	if [ "x$1" != "xfile" ];then
		input_name user
	else
		while true
		do
			read -p "Please Input The Imported list file name:" NAM
			[ -z "$NAM" ] && continue
			[ ! -f "$NAM" ] && continue
			IN_VUSER=(`cat $NAM`)
			input_name file
			[ "$?" == 0 ] && break
		done
	fi
	for vn in "${VUSER_NAME[@]}"
	do
		cre_vuser_conf "$vn"
		if [ "$?" == "0" ];then
			echo "$vn" >> ${VUSER_TXT}
			if [ "$USE_SSL" == "YES" ];then
				USERPW=`openssl rand -base64 6`
			else
				USERPW=$VUSER_PW
			fi
			echo "$USERPW" >> ${VUSER_TXT}
			echo "UserName:${vn},UserPasswd:${USERPW}"
			echo -e "\n"
		fi
	done
	echo "The User Name and User Password has been saved to \"${VUSER_TXT}\" file."
	unset VUSER_NAME
}

 show_users(){
	TXT=`sed 'N;s/\n/ /' ${VUSER_TXT}`
	echo "$TXT" | awk 'BEGIN{printf "%-16s %-20s\n","USERNAME","PASSWORD"}{printf "%-16s %-20s\n",$1,$2}'
}

 change_pw(){
	while true
	do
		read -p "Please Input the virtual ftp user name need to change password:" PW_USER
		if [ -z "$PW_USER" ];then
			continue
		fi
		chk_user_ex $PW_USER
		if [ "$?" == "1" ];then
			break
		fi
	done
	while true
	do
		read -p "Please Input the password:" PW_CH
		[ -z "$PW_CH" ] && continue
		PW_WC=`echo $PW_CH|wc -c`
		if [ "$PW_WC" -le "6" ];then
			echo "The password is too short,at least 6 character."
			continue
		else
			break
		fi
	done
	#PW_NR=`cat -n ${VUSER_TXT}|grep -E -A 1 "\<$PW_USER\>"|awk 'NR==2{print $1}'`
	sed -i "/${PW_USER}/{n;G;s/.*/$PW_CH/}" ${VUSER_TXT}
	cre_passwd_db
	unset PW_USER PW_CH PW_NR
	press_return
}

 del_user(){
	cp $VUSER_TXT $BAK_DIR
	echo "The user list file:$VUSER_TXT has been backup to $BAK_DIR"
	input_name del
	if [ "$?" == "1" ];then
		for i in "${VUSER_NAME[@]}"
		do
			del_vuser_conf $i
			sed -i "/\<$i\>/{N;d}" $VUSER_TXT
			echo "The User:${i} has been deleted successfully!"
		done
	else
		echo ""
	fi
	unset VUSER_NAME
	press_return
}
 cre_passwd_db(){
	db_load -T -t hash -f ${VUSER_TXT} ${VUSER_DB}
	chmod 600 ${VUSER_DB}
}

 dis_fw_se(){
	systemctl stop firewalld
	systemctl disable firewalld
	setenforce 0
	sed -i 's/enforcing$/disabled/' /etc/selinux/config
	press_return
}

 press_return(){

	read -p "Press "Enter" key return." RES
	case $RES in
		*)
			continue
			;;
	esac
	unset RES
#	echo "P
#	rel_press=$?
#	case $rel_press in
#		*)

}

 show_menu(){
	clear
	cat <<-EOF
	+----------------------------------+
	|   Manage VSFTP Virtual User      |
	+----------------------------------+
	| [1].Add single User              |
	| [2].Add User from file list      |
	| [3].Auto Config Vsftp            |
	| [4].Show users                   |
	| [5].Delete User                  |
	| [6].Change User password         |
	| [7].Disable firewall and selinux |
	| [0].Exit                         |
	+----------------------------------+
EOF
}
NUM="x"
while [ ! -z $NUM ]
do
	show_menu
	[ "$ERR" == "0" ] && echo "Error Input!";unset ERR
	read -p "Please Input the Number[ ]:" NUM
	[ -f $NUM ] && continue
	case $NUM in
		1)
			add_vuser_name user
			cre_passwd_db
			press_return
			;;
		2)
			add_vuser_name file
			cre_passwd_db
			press_return
			;;
		3)
			conf_vsftpd
			press_return
			;;
		4)
			show_users
			press_return
			;;
		5)
			del_user
			cre_passwd_db
			;;
		6)
			change_pw
			;;
		7)
			dis_fw_se
			;;
		0)
			exit 0
			;;
		*)
			clear
			ERR="0"
			#echo "Error input"
			#exit 0
			;;
	esac
done
