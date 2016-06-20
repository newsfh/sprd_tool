#!/bin/bash

##########################################################################
# author: hua.fang
# date: 2016/6/20
# function: split sleep log from kernel log
##########################################################################

filename=$(basename $0)

function help() {
	echo "$filename <kernel_log>"
}

function print_sleep_log() {
    file_name=$1
    is_sleep_start=0
    sleep_time=0
    line_num=0

	cat $file_name | while read LINE
	do
        LINE=$(echo $LINE | sed 's/\r$//');

		if [[ "$LINE" =~ "PM: suspend entry" ]]; then
            is_sleep_start=1
            line_num=0

            sleep_time=$((sleep_time+1))
            if (( $sleep_time != 1 )); then
                for (( i = 0; i < 3; i++ )); do
                    echo ""
                done
            fi

            echo $LINE
        elif [[ "$LINE" =~ "suspend: exit suspend" || "$LINE" =~ "PM: suspend exit" ]]; then
            is_sleep_start=0
            echo $LINE
        elif (( $is_sleep_start == 1 )); then
            if (( line_num < 200 )); then
                line_num=$((line_num+1))
                echo $LINE
            fi
		fi
	done
}

if [[ -n "$1" && -e $1 ]]; then
    print_sleep_log $1
else
    help
fi
