#!/bin/bash

##########################################################################
# author: hua.fang
# date: 2014/8/20
# function: repo sync
##########################################################################

if [ -d "./build" ]; then
	cd ./build
	git checkout .
	cd ..
fi

repo sync -d -c -q -j16

if [ -d "./build" ]; then
	patch_name=~/bin/build_android5.0.patch
	read LINE < ./version.txt

	if [[ $LINE =~ "sprdroid6" ]]; then
		patch_name=~/bin/build_android6.0.patch
	fi

	cd ./build
	git apply $patch_name
	cd ..
fi

## record the version in file
date >> ./version.txt
echo "# " >> version.txt
echo "--------------------------" >> ./version.txt

