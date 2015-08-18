#!/bin/sh

##################################################
#
# Author:summer.duan<summer.duan@spreadtrum.com>
# Date  :2014-02-17
# Description:
# generate patch from two manifest with revision
# Result:
# rmlist:deleted files. execute next cmd in repo code workspace,you can delete relative files
#        cat rmlist|xargs rm -rf 
# cplist:changed and added files
# buglist:bugids
#
##################################################

# define this parameters,the manifest xml file must exists.
BASE_DIR="/home/likewise-open/SPREADTRUM/hua.fang/server_ss/android_shark/.repo/projects"  
patch_path="/home/likewise-open/SPREADTRUM/hua.fang/work/patch/R1.7.1"
base_default_xml="$patch_path/base.xml"
head_default_xml="$patch_path/head.xml"
# define

patch_dir="$patch_path/patch"
tmp_base_list="$patch_dir/base.list"
tmp_head_list="$patch_dir/head.list"
rmlist="$patch_dir/rmlist"
cplist="$patch_dir/cplist"
buglist="$patch_dir/buglist"
base_version="$patch_dir/base"
head_version="$patch_dir/head"

if [ -d "$patch_dir" ]; then
  rm -rf $patch_dir/*
fi

mkdir -p $base_version
mkdir -p $head_version

[ "$base_default_xml" -a -f $base_default_xml ] &&
sed -e '/<project/!d' $base_default_xml|sed "s/.*name=\"//g"|sed "s/\".*//g"|sort >$tmp_base_list

[ "$head_default_xml" -a -f $head_default_xml ] &&
sed -e '/<project/!d' $head_default_xml|sed "s/.*name=\"//g"|sed "s/\".*//g"|sort >$tmp_head_list

# find delete repos and new added repos
rmrepos=$(diff $tmp_base_list $tmp_head_list | grep "^<" | cut -c3-)
newrepos=$(diff $tmp_base_list $tmp_head_list | grep "^>" | cut -c3-)

echo -e "$rmrepos" >>$rmlist
echo -e "$newrepos" >>$cplist

for onerepo in $newrepos
do
  onerepoline=$(grep "\"$onerepo\"" $head_default_xml)
  prjheadpath=$(echo $onerepoline | sed -e '/<project/!d' -e '/path=/!d'|sed "s/.*path=\"//g"|sed "s/\".*//g")
  if [ -z "$prjheadpath" ]; then
    prjheadpath=$onerepo
  fi

  prjheadrev=$(echo $onerepoline | sed "s/.*revision=\"//g" | sed "s/\".*//g")
  if [ "$prjheadrev" ]; then
    cd $BASE_DIR/${prjheadpath}.git
    git archive --format=tar --prefix=$prjheadpath/ $prjheadrev  |(cd $head_version && tar xf -)
  fi
done

# compare one by one repo
while read line
do
  prjbasepath=$(echo $line | sed -e '/<project/!d' -e '/name=/!d'|sed "s/.*name=\"//g"|sed "s/\".*//g")
  if [ "$prjbasepath" ]; then
    prjbaserev=$(echo $line| sed "s/.*revision=\"//g" | sed "s/\".*//g")
    prjheadrev=$(grep "\"$prjbasepath\"" $head_default_xml | sed "s/.*revision=\"//g" | sed "s/\".*//g")
    if [ "$prjbaserev" = "$prjheadrev" ]; then
      continue
    fi

    prjbasepathtmp=$(echo $line | sed -e '/<project/!d' -e '/path=/!d'|sed "s/.*path=\"//g"|sed "s/\".*//g")
    if [ "$prjbasepathtmp" ]; then
      prjbasepath=$prjbasepathtmp
    fi
    echo "$prjbasepath:$prjbaserev:$prjheadrev"

    if [ -d "${BASE_DIR}/${prjbasepath}.git" ]; then
      cd $BASE_DIR/${prjbasepath}.git
      if [ -z "$prjheadrev" ]; then
        git archive --format=tar --prefix=$prjbasepath/ $prjbaserev |(cd $base_version && tar xf -)
        continue
      fi
      deletefiles=$(git diff $prjbaserev..$prjheadrev --name-status | grep "^[D]" | cut -c3- | sort)
      if [ "$deletefiles" ]; then
        echo -e "$deletefiles" | sed "s|^|$prjbasepath/|g" >>$rmlist
      fi
      changefiles=$(git diff $prjbaserev..$prjheadrev --name-status | grep "^[M]" | cut -c3- | sort)
      if [ "$changefiles" ]; then
        echo -e "$changefiles" | sed "s|^|$prjbasepath/|g" >>$cplist
      fi
      newaddfiles=$(git diff $prjbaserev..$prjheadrev --name-status | grep "^[A]" | cut -c3- | sort)
      if [ "$newaddfiles" ]; then
        echo -e "$newaddfiles" | sed "s|^|$prjbasepath/|g" >>$cplist
      fi
echo "{$prjbasepath},  {$prjbaserev}, {$deletefiles}, {$changefiles}"
      git archive --format=tar --prefix=$prjbasepath/ $prjbaserev $deletefiles $changefiles |(cd $base_version && tar xf -)
      cd $BASE_DIR/${prjbasepath}.git
echo "{$prjbasepath}, {$prjheadrev}, {$newaddfiles}, {$changefiles}"
      git archive --format=tar --prefix=$prjbasepath/ $prjheadrev $newaddfiles $changefiles |(cd $head_version && tar xf -)

      cd $BASE_DIR/${prjbasepath}.git
      bugids=$(git log --format=%s $prjbaserev..$prjheadrev | sed -nr "s/(^Bug\s*#)([0-9]*)(.*)/\2/pi" |sort |uniq)
      if [ "$bugids" ]; then
        echo "---------$prjbasepath---------" >>$buglist
        echo "$bugids" >>$buglist
      fi

    fi
  fi

done <$base_default_xml
