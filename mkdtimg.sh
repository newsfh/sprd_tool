#!/bin/bash

filename=$(basename $0)
dtimg="dt.img"
status="none"
temp_dir=".temp_dtimg_build_folder"
declare -a dts_array

TOOL_DTC_FOLDER=~/bin/other
TOOL_DTC=$TOOL_DTC_FOLDER/dtc
TOOL_DTBTOOL=~/bin/other/dtbTool

function help() {
	echo "$filename [-h|-i <dts>|-o <img>]"
	echo "  -h: help"
	echo "  -i: input dts files"
	echo "  -o: output dt.img file"

	exit
}

function push_content {
	if [[ $status == "input" ]]; then
		dts_array[${#dts_array[@]}]=$1
	elif [[ $status == "output" ]]; then
		dtimg=$1
	fi
}

if (($#>0)); then
	while [ -n "$1" ]; do
		case $1 in
			-h) help ;;
			-i) status="input" ;;
			-o) status="output" ;;
			*) push_content $1 ;;
		esac
		shift 1
	done
else
	help
fi

if ((${#dts_array[@]} == 0)); then
	help
fi

echo "input: ${dts_array[@]}"
echo "output: $dtimg"

if [ -e $temp_dir ]; then
	rm -rf $temp_dir
fi
mkdir $temp_dir

for dts_file in ${dts_array[@]}; do
	if [ -e $dts_file ]; then
		$TOOL_DTC -I dts -O dtb $dts_file -o $temp_dir/$dts_file.dtb
	fi
done

$TOOL_DTBTOOL -o $dtimg ~/temp/$temp_dir/ -p $TOOL_DTC_FOLDER/

rm -rf $temp_dir

