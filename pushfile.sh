#!/bin/bash

project=$1
branch=$2

if [[ -z $project || -z $branch ]]; then
	repo_info="$(repo info .)"
	echo "$repo_info"
	project=$(echo "$repo_info" | awk '/Project:/{print $2}')
	branch=$(echo "$repo_info" | awk '/Current revision:/{print $3}')
#	project=$(repo info . | awk '/Project:/{print $2}')
#	branch=$(repo info . | awk '/Current revision:/{print $3}')
fi

echo "Project: $project"
echo "Branch: $branch"
echo "========================================"

git push ssh://hua.fang@10.0.0.160:29418/$project HEAD:refs/for/$branch
