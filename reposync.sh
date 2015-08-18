#!/bin/sh

if [ -d "./build" ]; then
	cd ./build
	git checkout .
	cd ..
fi

repo sync -d -c -q -j16

if [ -d "./build" ]; then
	cd ./build
	git apply ~/build.patch
	cd ..
fi

## record the version in file
date >> ./version.txt
echo "# " >> version.txt
echo "--------------------------" >> ./version.txt

