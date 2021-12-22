#!/bin/bash
#
# Author: Steve Stonebraker
# Description: This will install mod_security 2.7.5
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
logfile=$ourPath/mod_security_install.log
mkfifo ${logfile}.pipe
tee < ${logfile}.pipe $logfile &
exec &> ${logfile}.pipe
rm ${logfile}.pipe

########################################
########################################
#These packages are required at a minimum to build modsecurity + their component libraries
print_status "Installing base packages:  build-essential libxml2 libxml2-dev liblua5.1-0-dev libpcre3 libaprutil1 libapr1 lua-lgi-dev apache2-dev libcurl4-openssl-dev "
declare -a packages=(  build-essential libxml2 libxml2-dev liblua5.1-0-dev libpcre3 libaprutil1 libapr1 lua-lgi-dev apache2-dev libcurl4-openssl-dev );
install_packages ${packages[@]}
########################################

########################################
#Install Modsecurity version 2.7.5
install_mod_security "2.7.5"
########################################

printline
print_status "to test if your rule is working run this and check audit console:";printline
print_status "curl -k http://localhost/?test=MY_UNIQUE_TEST_STRING"
print_status "To debug: /opt/modsecurity/var/log/debug.log";printline
print_good "Install Complete!"