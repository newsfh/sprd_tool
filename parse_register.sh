#!/bin/bash

##########################################################################
# author: hua.fang
# date: 2016/6/16
# function: display register detail
##########################################################################


##################################   Register Format
# format:
#   === REG_NAME(reg_addr) ===
#	bit_name offset [len] [detail]
#	bit_name offset [len] [detail]
#
# explaination:
#   'REG_NAME' must be upper case, 'reg_addr' must be lower case
#   separate by space, so could not have space between each info
#
#   there are 3 types now, the parser would detect it automatically by parameters.
#	switch: 'len' & 'detail' must be null
#         array count must be 2
#         eg. ADC_EB 0
#	enum: detail is "<info of 0> <info of 1> ..."
#         array count must be larger than 5.
#         eg. PD_CA7_C1_STATE 8 4 WAKEUP POWER_ON_SEQ POWER_ON RST_ASSERT RST_GAP RESTORE ISO_OFF SHUTDOWN ACTIVE STANDBY ISO_ON SAVE_ST SAVE_GAP POWER_OFF BISR_RST BISR_PROC
#	value: detail is "<start value> <step value>", 'start' & 'step' can not be fractional digit
#         array count must be 5, 'len' is more than 1.
#         eg. PD_CA7_C0_STATE 4 4 0 1
#   # - comment


##################################   register header file
source "regs_sharkls.sh"


##################################   basic OS command
if [ -e /system/bin/sh ]; then
	LOOKAT="lookat"
	PRINTF="busybox printf"
	TR="busybox tr"
	AWK="busybox awk"
	SED="busybox sed"
	BASENAME="busybox basename"
	EXPR="busybox expr"
else
	LOOKAT="adb shell lookat"
	PRINTF="printf"
	TR="tr"
	AWK="awk"
	SED="sed"
	BASENAME="basename"
	EXPR="expr"
fi


##################################   basic translation function
function hex() {
	printf "0x%08x" $1
}

## not include "0x"
function hex_1() {
	printf "%08x" $1
}

function hex1() {
	printf "0x%02x" $1
}

function hex3() {
	printf "0x%02x" $1
}

function hex4() {
	printf "0x%02x" $1
}

function hex7() {
	printf "0x%02x" $1
}

function bin_hex() {
	value=$1
	vshift=$2
	vmask=$3
	echo -n $(`expr hex$vmask` $(($value >> $vshift & $vmask)))
}

## translate to upper case
function bin_hex_trans() {
	value=$1
	vshift=$2
	vmask=$3
	echo -n $(`expr hex_1` $(($value >> $vshift & $vmask)) | tr a-z A-Z)
}

###################################   type checking & printing
function check_current_line_type() {
    info=($@)
    arr_count=${#info[@]}
    if (( $arr_count < 2 )); then
        printf 'n'
    elif (( $arr_count == 2 )); then
        printf 's';
    elif (( $arr_count == 5 && ${info[2]} > 1 )); then
        printf 'v';
    elif (( $arr_count >= 5 )); then
        printf 'e';
    else
        printf 'n';
    fi
}

function print_bit_type() {
	reg_val=$1
	info=$2
	reg_bit=$3
	echo -n "[$reg_bit]"
	case `bin_hex $reg_val $reg_bit 1` in
		0x00) echo " //$info" ;;
		0x01) echo " $info" ;;
	esac
}

function print_enum_type() {
	reg_val=$1
    info=$2
	reg_offset=$3
	reg_len=$4
	arr=($@)

    reg_mask=$(( (1 << $reg_len) - 1))

	echo -n "[$((reg_offset+reg_len-1)):$reg_offset] $info : "
	index=$($PRINTF "%d" $(($reg_val >> $reg_offset & $reg_mask)))
	echo "${arr[$index+4]} "
}

function print_value_type() {
	reg_val=$1
	info=$2
	reg_offset=$3
	reg_len=$4
	start_val=$5
	val_step=$6

    reg_mask=$(( (1 << $reg_len) - 1))

	echo -n "[$((reg_offset+reg_len-1)):$reg_offset] $info : "
	vol=$(bin_hex_trans $reg_val $reg_offset $reg_mask)
	vol_dec=$(echo "obase=10; ibase=16; $vol"|bc);
	real_vol=$(echo $start_val+$vol_dec*$val_step|bc);
	echo $($PRINTF "0x%08x" $real_vol)
}


###################################   prase register
function parse_register() {
    reg=$1
    val=$2
    is_parse=0

	list_regs | while read LINE
	do
        LINE=$(echo $LINE | sed 's/\r$//');

		if [[ "$LINE" =~ "===" ]]; then
            if [[ "$LINE" =~ "$reg" ]]; then
                echo "$LINE  $val"
                is_parse=1
			else
                is_parse=0
            fi
        elif [[ "$is_parse" == "1" ]]; then
#arr=($LINE)
#echo "++++ ${#arr[@]} +++" ${arr[4]} " +++ ${arr[*]}"
            line_type=$(check_current_line_type $LINE)
            case $line_type in
				s) echo -n "$line_type"; print_bit_type $val $LINE ;;
				e) echo -n "$line_type"; print_enum_type $val $LINE ;;
				v) echo -n "$line_type"; print_value_type $val $LINE ;;
				*) ;;
			esac
		fi
	done
}

###################################   main
parse_register $1 $2

