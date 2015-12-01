#!/bin/bash

##########################################################################
# author: hua.fang
# date: 2014/8/20
# function: repo init
##########################################################################

## delete all manifest
rm -rf ./.repo/manifest*

### repo init
#repo init -u gitosis@sprdroid.git.spreadtrum.com.cn:android/platform/manifest -b $1

## repo init
#repo init -u gitadmin@10.0.0.233:android/platform/manifest -b $1
repo init -u gitadmin@gitsrv01.spreadtrum.com:android/platform/manifest.git -b $1
# repo init -u gitadmin@gitsrv01.spreadtrum.com:android/platform/manifest.git -b $1 --repo-url=gitadmin@gitsrv01.spreadtrum.com:tools/newrepo.git
# repo init -u ssh://samsung@59.151.42.244:29418/platform/cus-manifest.git -b sprdroid4.4_3.10 -m MOCORDROID4.4_3.10_W13.48.4.xml

## replace url with shanghai mirror
# sed -i 's/gitosis@sprdroid\.git\.spreadtrum\.com\.cn\:android/gitadmin@gitsrv01\.spreadtrum\.com\:android/g' .repo/manifests/default.xml

## record the version in file
echo $1 > ./version.txt
echo "=======================================================" >> ./version.txt

## reset
#repo forall -c 'git clean -df && git reset --hard HEAD'


