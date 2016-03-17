#!/bin/bash

##########################################################################
# author: hua.fang
# date: 2016/03/17
# function: cp file
##########################################################################

if [ $# -ne 2 ]; then
	filename=$(basename "$0")
	echo "error: param not right!"
	echo "  $filename <src_file> <out_folder>"
	exit
fi

src_file=$1
delta_path=$2

if [ ! -e $delta_path ]; then
	mkdir --parents $delta_path
fi

cp --parents $src_file $delta_path
