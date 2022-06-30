#!/bin/bash
#
# Author: Steve Stonebraker
# Date: 6/29/2022
# Purpose: Given a list of urls in a txt file, download all files
# Note: this will try to download them all at the same time
# usage: ./download_list_urls_aysnc.sh <filename>
#


INPUTFILE=$1

echo "" > output.txt 
for record in $(cat "${INPUTFILE}")
do
   nohup curl --silent -L -O -o /dev/null --connect-timeout 3 --max-time 6 -w "%{scheme} %{remote_ip} %{http_code}" "${record}" >> output.txt &
done