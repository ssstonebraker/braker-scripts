#!/bin/bash
#
# Author: Steve Stonebraker
# Date: 6/29/2022
# Purpose: Given a list of urls in a txt file, download all files
# Note: maximum ten concurrent threads
# usage: ./download_list_urls_aysnc.sh <filename>
#

# shellcheck disable=SC3028 # $RANDOM variable is undefined.
# shellcheck disable=SC2148 # shebang does not exist. because this script will work both "zsh" and "bash".
# shellcheck disable=SC2162 #  will mangle backslashes. it does not important for now.
# shellcheck disable=SC2068,SC2128,SC2086,SC2124,SC2294,SC2145,SC2198 # TODO about $* $@
# shellcheck disable=SC2059 # printf wrapper warning.
# shellcheck disable=SC2155 # command may give error. variable assignment should be in another line.
# shellcheck disable=SC2016 # single vs double quotes
# shellcheck disable=SC1004 # line splitting is true. we need both linefeed+ empty spaces.
# shellcheck disable=SC2046 # all cases are valid. word splitting is not important in those cases. 

INPUTFILE=$1

# wait until curl thread count less than ten to continue
__print_curl_threads() {
    while : ; do
      COUNT_CURL=$(ps -ef | grep "curl" | wc -l)
      if [ "$COUNT_CURL" -gt 10 ]; then
         echo "Threads still processing: $COUNT_CURL  "
         sleep 1
      else
         break
      fi
   done
}


echo "" > output.txt 
for record in $(cat "${INPUTFILE}")
do
   echo "processing ${record}"
   nohup curl --silent -L -O -o /dev/null --connect-timeout 3 --max-time 6 -w "%{scheme} %{remote_ip} %{http_code}" "${record}" >> output.txt &
   __print_curl_threads
done