#!/bin/bash
# Filename: cidr_to_ipset.sh
# Description: create ipset from cidr file
# Usage: ./cidr_to_ipset.sh <somefile>.txt
# Author: Steve Stonebraker
# Site: brakertech.com
#
# You can optain a list of cidr ip blocks
# by country at
# http://www.ip2location.com/free/visitor-blocker
#


if [ "$#" == "0" ]; then
    echo "No arguments provided, please provide file name"
    exit 1
fi
#assign user's provided input to "fullfile"
fullfile=$1

#Check to make sure the user provided a valid file
if   [ -d "${fullfile}" ] ; then
	echo "${fullfile} is a directory";
	exit 1;
elif [ -f "${fullfile}" ]
	then echo "${fullfile} is a valid file";
else echo "${fullfile} is not valid";
     exit 1
fi

#parse the basename
#ex:  USA.txt becomes "USA"
filename=$(basename "$fullfile")
country="${filename%.*}"

echo "processing: $country"


#Create ipset hash set
ipset create -exist ${country} hash:net family inet maxelem 4294967295
ipset flush ${country}
for IP in $( cat $fullfile )
do
ipset -A ${country} $IP -exist
done

echo "ipset created and also exported to {country}.ipset"
ipset save > ${country}.ipset