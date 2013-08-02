#!/bin/bash
#
# Author: Steve Stonebraker
# Name: change_hostname.sh
# Usage: ./change_hostname.sh <new_hostname>
#
# Description: This will change your system's hostname on a Debian distribution
#
#

########################################
#source another file (it has functions we use)
readonly ourPath="$(dirname $0)"
readonly commonFunctions="$ourPath/common_functions"
if [ ! -e "$commonFunctions" ]; then
            echo "common_functions not found... downloading"
        cd $ourPath
        curl -s -O  "https://raw.github.com/ssstonebraker/braker-scripts/master/common_functions"
fi

if [ -e "$commonFunctions" ]; then
        source "$commonFunctions"
        print_good "loaded commonFunctions file"
else
        echo "common_functions not found... exiting"
        exit 1;
fi
########################################

system_update_hostname $1
