#!/bin/bash

if [ -n "$1" -a -n "$2" ]; then
#	sudo cp /etc/cntlm.conf /etc/cntlm.conf.bk
#	sudo sed -i "s/${1}/${2}/g" /etc/cntlm.conf

	sed -i "s/${1}/${2}/g" ~/.bashrc
	sed -i "s/${1}/${2}/g" ~/bin/cntser.sh
else
	FILE_NAME="$(basename "$0")"
	echo "$FILE_NAME <old_psw> <new_psw>"
fi
