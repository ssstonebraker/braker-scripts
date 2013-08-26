#!/bin/bash
# Name: install_ipset.sh
# Author: Steve Stonebraker
# Date: 8/26/2013
# Purpose: Install ipset on ubuntu or centos/redhat distros
# Usage ./install_ipset.sh
#
####################################
# Exit if program echo does not exist (this allows us to do one line if statements)
[ ! -x "$(which echo)" ] && exit 1
########################################
# pretty printing functions
function print_status { echo -e "\x1B[01;34m[*]\x1B[0m $1"; }
function print_good { echo -e "\x1B[01;32m[*]\x1B[0m $1"; }
function print_error { echo -e "\x1B[01;31m[*]\x1B[0m $1"; }
function print_notification { echo -e "\x1B[01;33m[*]\x1B[0m $1"; }
function printline { hr=-------------------------------------------------------------------------------------------------------------------------------
printf '%s\n' "${hr:0:${COLUMNS:-$(tput cols)}}"
}
####################################
# print message and exit program
function die { print_error "$1" >&2;exit 1; }
########################################    
#Make sure only root can run our script
function proceed_if_root { if [[ $EUID -ne 0 ]]; then die "This script must be run as root"; fi }
##############
# Get Current Distro
# return value of current distro
# example usage: 
# distro=$(get_distro)
# if [ "$distro" = "ubuntu" ]; then
#                db_stop || true
#        fi
function get_distro {
	local out=$(lsb_release -is 2> /dev/null)

	case $out in
        RedHatEnterpriseServer)
            echo "redhat"
            ;;
        CentOS)
            echo "redhat"
            ;;
        Ubuntu)
            echo "ubuntu"
            ;;
        *)
            # RHEL 6.0 did not have lsb_release, for example, and suse depends on qt3, libqt4, mesa, etc.
            # So adding lsb to our dependencies is kind of a pain
            if [ -e "/etc/redhat-release" ]; then
                    echo "redhat"
            elif [ -e "/etc/SuSE-release" ] ; then
                    echo "sles"
            else
                    return 1
            fi
	esac
}

########################################
# check if ipset installed, if not install it
# die if os not ubuntu or redhat/centos
function require_ipset {
	distro=$(get_distro)
	if [ "$distro" = "ubuntu" ]; then
		which ipset >/dev/null || { apt-get update; apt-get -y install ipset; }
	elif [ "$distro" = "redhat" ] ; then
		which ipset >/dev/null || { yum -y install ipset; }
	else
		die "unable to detect distro"
	fi
	which ipset >/dev/null && print_good "ipset is installed" || die "unable to install ipset"
}

proceed_if_root
require_ipset