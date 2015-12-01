#!/bin/bash

##########################################################################
# author: hua.fang
# date: 2014/8/20
# function: read regulator sys node
##########################################################################

# readme:
# 将文件push到手机里，运行即可

# usage:
# 如果带参数，读取各ldo当前的电压值
# 如果不带参数，则读取各ldo当前的配置数据

if [ -n "$1" ]; then
	regdir="/d/sprd-regulator"
	reginfo="enable voltage"
else
	regdir="/sys/class/regulator"
	reginfo="name min_microvolts max_microvolts microvolts state"
fi

reglist=$(adb shell ls $regdir)

for reg in $reglist
do
	echo "----------- $reg ------------"
	for info in $reginfo
	do
		echo "dddddddddddddddd  $regdir/$reg/$info dddddddddd"
		adb shell cat $regdir/$reg/$info
	done
done

