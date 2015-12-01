#!/bin/sh

##########################################################################
# author: hua.fang
# date: 2014/11/20
# function: parse ramdisk file
##########################################################################

if [ -n "$1" -a -n "$2" ]; then
	cp $1 ramdisk.img.gz
	gunzip ramdisk.img.gz

	mkdir $2
	cd $2
	cpio -i -F ../ramdisk.img
else
	FILE_NAME="$(basename "$0")"
	echo "$FILE_NAME <src_ramdisk> <dst_dir>"
fi
