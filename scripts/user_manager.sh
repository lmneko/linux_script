#!/bin/bash
#2018年7月6日21:17:46
#管理linux用户和组脚本
#auther xufeng
#####################
USERGROUP=""
USERNAMES=""
PW_NEED="YES"            #if PW_NEED=YES,it will create user passwd with openssl     
HOME_PERM="YES"
function chk_user_ex(){
	USER_ETC=(`cat /etc/passwd|awk -F: '{print $1}'`)
	for i in "${USER_ETC[@]}"
	do
		if [ "$u" == "$i" ];then
			return 1
			break
		fi
	done
	return 0
}

function chk_group_ex(){
	GROUP_ETC=(`cat /etc/group|awk -F: '{print $1}'`)
	for i in "${GROUP_ETC[@]}"
	do
		if [ "$1" == "$i" ];then
			return 1
			break
		fi
	done
	return 0
}

function show_users(){
	cat /etc/passwd | awk -F: 'BEGIN{printf "%-8s %-16s %-8s %-8s\n","NUM","USER","UID","GID"}{printf "%-8s %-16s %-8s %-8s\n",NR,$1,$3,$4}'
	press_return
}

function show_groups(){
	cat /etc/group | awk -F: 'BEGIN{printf "%-8s %-16s %-8s\n","NUM","GROUP","GID"}{printf "%-8s %-16s %-8s\n",NR,$1,$3}'
	press_return
}

function cre_user() {
    which openssl || yum -y install openssl >>/dev/null 2&>1
    [ -n "${USERGROUP}" ] && groupadd -r ${USERGROUP}
    for i in ${USERNAMES}	
    do
        if [ -n "${USERGROUP}" ];then
                useradd -G ${USERGROUP} ${i}
        else
                useradd ${i}
        fi
        if [ "${PW_NEED}" == "YES" ];then
			USERPW=`openssl rand -base64 6`
		else
			USERPW="${i}"
		fi
		echo "$USERPW"|passwd --stdin ${i}
		[ "${HOME_PERM}" == "YES" ] && chmod 711 /home/${i}	
		echo -e "\n"
		echo "UserName:${i},UserPasswd:${USERPW}"|tee -a output_passwd.txt
    done
    echo "The passwd has been saved to \"output_passwd.txt\" file. "
	unset USERNAMES
	press_return
}

function input_name(){
	if [ "$2" == "pw" ];then
		ACTION="Change Password"
	fi
	while true
	do
		read -p "Please input the $1 Name need to ${ACTION:-delete}:" NAME
		if [ -z "$NAME" ];then
			echo "Null Input!"
			continue
		fi
		if [ "$1" == "User" ];then
			chk_user_ex $NAME
		elif [ "$1" == "Group" ];then
			chk_group_ex $NAME
		fi
		#chk_user_ex $NAME
		if [ "$?" == "0" ];then
			echo -e "[\033[31m Error! \033[0m] The $1 $NAME has not found!"
		else
			break
		fi
		read -p "Weather continue Input?[Y/N]" RES
		if [[ "$RES" =~ (y|yes|Y|Yes|YES) ]];then
			continue
		else
			break
		fi
	done
	if [ "$1" == "User" ];then
		USERNAME=$NAME
	elif [ "$1" == "Group" ];then
		GROUPNAME=$NAME
	fi
	unset NAME
	unset ACTION
}

function change_pw(){
	input_name User pw
	passwd $USERNAME
	unset USERNAME
	press_return
}

function del_user(){
	input_name User
	userdel $USERNAME 2>>/dev/null && echo "Delete User:$USERNAME successful!"
	unset USERNAME
	press_return
}

function del_group(){
	input_name Group
	userdel $GROUPNAME 2>>/dev/null && echo "Delete Group:$GROUPNAME successful!"
	press_return
}

function press_return(){
    read -p "Input \"0\" return：" RES
			while true
			do
				if [ "$RES" != "0" ];then
					read -p "Input \"0\" return:" $RES
				else
					return
				fi
			done
	unset RES
}

function show_menu(){
	cat <<-EOF
	+------------------------------+
	|    Manage User and Group     |
	+------------------------------+
	| [1].Add single user          |
	| [2].Add user from file list  |
	| [3].Show users               |
	| [4].Show groups              |
	| [5].Delete system user       |
	| [6].Delete system group      |
	| [7].Change user password     |
	| [0].Exit                     |
	+------------------------------+
EOF
}

while true
do
	show_menu
	read -p  "Please input the [ ] Number:" NUM
	case $NUM in
		1)	
			read -p "Please input the user name which need to add:" USERNAMES
			cre_user
			;;
		2)	
			read -p "Please input the file to add user:" FILELIST
			USERNAMES=`cat ${FILELIST}`
			cre_user
			;;
		3)	
			show_users
			;;
		4)	
			show_groups
			;;
		5)	
			del_user
			;;
		6)	
			del_group
			;;
		7)	
			change_pw
			;;
		0)	
			exit 0
			;;
		*)	
			echo "Eorror Input!"
			continue
			;;
	esac
done
