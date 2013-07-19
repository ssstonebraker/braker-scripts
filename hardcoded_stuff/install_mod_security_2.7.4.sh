#!/bin/bash
#
# Author: Steve Stonebraker
# Description: This will install mod_security 2.7.4
#            for ubuntu 12.04 precise
#
#
set -x
########################################
#source another file (it has functions we use)
readonly ourPath="$(dirname $0)"
readonly commonFunctions="$ourPath/common_functions"
if [ -e "$commonFunctions" ]; then
        source "$commonFunctions"
        print_good "loaded commonFunctions file"
else
        echo "common_functions not found"
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
install_mod_security "2.7.4"
########################################
