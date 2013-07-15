#!/bin/bash
#
# Author: Steve Stonebraker
# name: change_hostname.sh
# usage: ./change_hostname.sh <new_hostname>
#

function system_primary_ip {
	# returns the primary IP assigned to eth0
	echo $(ifconfig eth0 | awk -F: '/inet addr:/ {print $2}' | awk '{ print $1 }')
}

function system_update_hostname {
	 # system_update_hostname(system hostname)
	    if [ -z "$1" ]; then
	        echo "system_update_hostname() requires the system hostname as its first argument"
	        return 1;
	    fi
	HOSTNAME=$1
	HOST=`echo $HOSTNAME | sed 's/\(\[a-z0-9\]\)*\..*/\1/'`
	HOSTS_LINE="`system_primary_ip`\t$HOSTNAME\t$HOST"
	echo "$HOST" > /etc/hostname
	sed -i -e "s/^127\.0\.1\.1\s.*$/$HOSTS_LINE/" /etc/hosts
	/bin/hostname -F /etc/hostname
	/etc/init.d/hostname restart
}