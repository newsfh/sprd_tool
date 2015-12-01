#!/bin/sh

##########################################################################
# author: hua.fang
# date: 2014/10/20
# function: flash image
##########################################################################

#PART_FOLDER="/dev/block/platform/sprd-sdhci.3/by-name";
PART_FOLDER="/dev/block/platform/sdio_emmc/by-name";
SCRIPT_NAME=$(basename $0)

list_part_name()
{
	adb shell ls $PART_FOLDER;
}

# check whether partition name exists or not
is_exist()
{
	PART_NAME=$PART_FOLDER/$1;
	EXIST=$(adb shell ls $PART_NAME | grep "No such file or directory")
	if [ -z "${EXIST}" ]; then
		return 1
	else
		return 0
	fi
}

help()
{
	echo "param error, please use"
	echo "$SCRIPT_NAME [-l] | [<part_name> <image_file>]"
}

# download the image
flash()
{
	IMAGE_NAME=$(basename $2)
	PART_NAME=$PART_FOLDER/$1

	adb root
	sleep 2
	adb remount
	sleep 1

	echo "push file $2 to /data/$IMAGE_NAME";
	adb push $2 /data/$IMAGE_NAME

	echo "flash /data/$IMAGE_NAME to $PART_NAME"
	adb shell dd if=/data/$IMAGE_NAME of=$PART_NAME

	echo "rm /data/$IMAGE_NAME"
	adb shell rm /data/$IMAGE_NAME
}

if [ $# = 2 ]; then
	is_exist $1
	if [ $? = 1 ]; then
		if [ -e $2 ]; then
			flash $1 $2
		else
			echo "image not exist"
		fi
	else
		echo "partition name not exist"
	fi
elif [ $# = 1 ]; then
	if [ $1 = "-l" ]; then
		list_part_name
	else
		help
	fi
else
	help
fi

