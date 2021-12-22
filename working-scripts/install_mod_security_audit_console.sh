#!/bin/bash
#
# Author: Steve Stonebraker
# Description: This will install mod_security 2.7.4
#            for ubuntu 12.04 precise
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

########################################
proceed_if_root
check_if_ubuntu_12
########################################
#Setup Log file
logfile=$ourPath/mod_security_audit_console.log
mkfifo ${logfile}.pipe
tee < ${logfile}.pipe $logfile &
exec &> ${logfile}.pipe
rm ${logfile}.pipe

########################################
install_mod_security_audit_console