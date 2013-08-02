#!/bin/bash
#
# Author: Steve Stonebraker
# Name: change_hostname.sh
# Usage: ./change_hostname.sh <new_hostname>
#
# Description: This will change your system's hostname on a Debian distribution
#
#


printline() {
hr=---------------------------------------------------------------\
----------------------------------------------------------------
printf '%s\n' "${hr:0:${COLUMNS:-$(tput cols)}}"
}
########################################
function print_status ()
{
    echo -e "\x1B[01;34m[*]\x1B[0m $1"
}

function print_good ()
{
    printline
    echo -e "\x1B[01;32m[*]\x1B[0m $1"
    printline
}

function print_error ()
{
    echo -e "\x1B[01;31m[*]\x1B[0m $1"
}

function print_notification ()
{
  echo -e "\x1B[01;33m[*]\x1B[0m $1"
}
########################################
function system_primary_ip {
	# returns the primary IP assigned to eth0
	echo $(ifconfig eth0 | awk -F: '/inet addr:/ {print $2}' | awk '{ print $1 }')
}

########################################
function replaceText
{
sed -i "s|${1}|${2}|g" "${3}"
}
########################################

function system_update_hostname {
	 # system_update_hostname(system hostname)
	    if [ -z "$1" ]; then
	        echo "system_update_hostname() requires a hostname as its first argument"
	        return 1;
	    fi

	#Existing hostname
	old_hostname=$(cat /etc/hostname)
	print_notification "Existing hostname is ${old_hostname}"

	#user provided new hostname
	new_hostname=$1

	#Parse the hostname without any prepending domain
    new_hostname_trimmed=$(echo $new_hostname | cut -d "." -f1)
    print_notification "New hostname ${new_hostname_trimmed}"

    # Make sure new hostname and old hostname are different
    old_hostname=$(cat /etc/hostname)
    if [ "$new_hostname_trimmed" == "$old_hostname" ]; then
            print_error "new hostname and current hostname match!"
            return 1
    fi

    # clean 127.0.0.1 line, removing occurances of current hostname
    declare -a localhost_line=(`grep "127.0.0.1" /etc/hosts `);
    declare -a old_127_trimmed=( ${localhost_line[@]/$old_hostname*/} )

    # if the user didn't provide a FQDN then just append hostname they provided
    if [ "$new_hostname" == "$new_hostname_trimmed" ]; then
            new_127="${old_127_trimmed[@]} $new_hostname"

    # if user provided a FQDN as hostname, append that and hostname
    else
            new_127="${old_127_trimmed[@]} $new_hostname $new_hostname_trimmed"
    fi

    # Create new hosts file with our new 127.0.0.1 line first
    echo "${new_127}" > hosts.tmp
    grep -v "127.0.0.1" /etc/hosts >> hosts.tmp

    # Apply the new hosts file
    mv hosts.tmp /etc/hosts

    # Apply the new hostname
    echo "${new_hostname_trimmed}" > /etc/hostname
    echo "${new_hostname_trimmed}" > /proc/sys/kernel/hostname
    /bin/hostname -F /etc/hostname
    /etc/init.d/hostname restart >/dev/null 2>/dev/null
    print_good "Hostname Changed: ${new_hostname_trimmed}"
    print_good "/etc/hosts Modified: ${new_127}"
    print_notification "Logout and then back in to see the new hostname in your bash prompt"
    echo -e "\n"
}

system_update_hostname $1
