#!/bin/bash

##########################################################################
# author: hua.fang
# date: 2016/1/21
# function: check build info in sysdump and vmlinux
# 			check_buildinfo.sh <ap_sysdump_file>
#			vmlinux should be in the same folder
##########################################################################

filename=$(basename $0)
function message()
{
	echo "  $filename <sysdump_file>"
}

function read_buildinfo()
{
	IS_BUILDINFO=0
	strings $1 | while read LINE
	do
		if [[ $LINE = "Kernel Build Info :" ]]; then
			((IS_BUILDINFO++))
		fi

		if (($IS_BUILDINFO>0 && $IS_BUILDINFO<6)); then
			echo $LINE
			((IS_BUILDINFO++))
		elif (($IS_BUILDINFO>=6)); then
			return
		fi
	done
}

if [ $# -lt 1 ]; then
	echo "param number error!"
	message;
	exit
fi

if [ ! -e $1 ]; then
	echo "sysdump files not exist!"
	message;
	exit
fi

if [ ! -e "vmlinux" ]; then
	echo "vmlinux not exist!"
	message;
	exit
fi

echo "====  buld info in vmlinux  ===="
read_buildinfo "vmlinux"
echo " "

echo "====  buld info in sysdump  ===="
read_buildinfo $1

