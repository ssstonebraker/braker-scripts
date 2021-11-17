#!/bin/bash
#
# Author: Steve Stonebraker
# Date: 11-17-2021 
#Usage: /ip_lookup_from_list.sh <filename>
# Purpose: perform nslookup on a list of fully qualified domain names and print the output

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "Provide input file to perform lookups, $# arguments provided"


INPUTFILE=$1

for record in $(cat "${1}")
do
#        printf "$record\t"

        IPS=$(nslookup "${record}" | gawk -F"Address: " '{ print $2 }' | grep -v "^$")
        echo "$IPS"

done
