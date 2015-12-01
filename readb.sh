#!/bin/bash

##########################################################################
# author: hua.fang
# date: 2014/8/20
# function: re-start adb service
##########################################################################

sudo adb kill-server
sudo adb start-server
sudo adb devices
