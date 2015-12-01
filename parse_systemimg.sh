#!/bin/bash

##########################################################################
# author: hua.fang
# date: 2015/11/20
# function: parse system.img
##########################################################################

filename=$(basename $0)
status="none"
input_file=
input_image=
output_folder=temp_image_folder

function help() {
	echo "$filename [-h|-i <image> -o <folder>|-u <folder>]"
	echo "  -h: help"
	echo "  -i: input image file"
	echo "  -o: mount to folder"
	echo "  -u: umount folder"

	exit
}

function push_content {
	case $status in
		"none") input_file=$1; status="output" ;;
		"input") input_file=$1; status="output" ;;
		"output") output_folder=$1 ;;
		"umount") output_folder=$1 ;;
	esac
}

if (($#>0)); then
	while [ -n "$1" ]; do
		case $1 in
			-h) help ;;
			-i) status="input" ;;
			-o) status="output" ;;
			-u) status="umount" ;;
			*) push_content $1 ;;
		esac
		shift 1
	done
else
	help
fi

if [[ $status == "umount" ]]; then
	if [ -e $output_folder ]; then
		sudo umount $output_folder
	fi
else
	if [ -e $input_file ]; then
		if [ ! -e $output_folder ]; then
			mkdir $output_folder
		fi

		input_image=$input_file
		if [[ -z $(file $input_image | grep "ext4 filesystem data") ]]; then
			input_image=$input_file.ext4
			simg2img $input_file $input_image
		fi

		sudo mount -t ext4 -o loop $input_image $output_folder
	fi
fi
