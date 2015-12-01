#!/bin/sh

##########################################################################
# author: hua.fang
# date: 2014/11/20
# function: mk ramdisk.img
##########################################################################

if [ -n "$1" -a -n "$2" ]; then
	cd $1
	find . |cpio -ov -H newc |gzip > ../$2
else
	FILE_NAME="$(basename "$0")"
	echo "$FILE_NAME <src_dir> <dst_name>"
fi
