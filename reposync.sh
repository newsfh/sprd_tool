#!/bin/bash

repo sync -d -c -j2

## record the version in file
date >> ./version.txt
echo "# " >> version.txt
echo "--------------------------" >> ./version.txt

