#!/bin/bash
#Auther: xufeng
#data: 2018-10-08 13:35:00
#function: create lvm part
#

VG_NAME=data
LV_NAME=data
MNT_DIR=/data
PART_FS=xfs
count=0
basename=`basename $0`

help(){
	echo "Usage: $basename --vgname=[vgname] --lvname=[lvname] --format=[part format] [disk_device]"
	echo "Example: $basename --vgname=data --lvname=data --format=xfs /dev/sdb /dev/sdc
	$basename /dev/sdb /dev/sdc /dev/sdd"
}

while (($#>0))
do
	case ${1%%=*} in
		--vgname)
			VG_NAME=${1##*=}
			;;
		--lvname)
			LV_NAME=${1##*=}
			;;
		--format)
			PART_FS=${1##*=}
			;;
		*)
		 	DEV_OPT=$@&&shift $#
		 	;;
	esac
	shift
done

if [ -z $DEV_OPT ];then
	help
	exit 1;
fi

for xa in $DEV_OPT
do
	if [ ! -b $xa ];then
		echo -e "\e[31m[Error]\e[0m Disk $xa is not exist"
		exit 1;
	fi
	parted -s $xa mklabel gpt mkpart primary 0 -1 toggle 1 lvm
	pvcreate ${xa}1
	PV_PART[$count]=${xa}1
	let count++
done

if ! vgcreate $VG_NAME PV_PART[@] && lvcreate -l 100%FREE -n /dev/$VG_NAME/$LV_NAME ;then
	echo -e "\e[31m[Error]\e[0m Create lvm part /dev/$VG_NAME/$LV_NAME failed"
	exit 1
fi

if ! mkfs.$PART_FS /dev/$VG_NAME/$LV_NAME;then
	echo -e "\e[31m[Error]\e[0m Make part format $PART_FS error"
	exit 1
fi

[ ！ -d $MNT_DIR ] && mkdir -p $MNT_DIR

#cp /etc/fstab /etc/fstab_bak
echo "/dev/$VG_NAME/$LV_NAME $MNT_DIR $PART_FS defaults,relatime 0 0" >> /etc/fstab
if mount -a;then
	echo -e "\e[32mOK\e[0m Lvm part /dev/$VG_NAME/$LV_NAME mount on $MNT_DIR successful"
else
	sed -i '$d' /etc/fstab
fi
