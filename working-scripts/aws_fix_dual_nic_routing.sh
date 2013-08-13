#!/bin/bash
#
# Author: Steve Stonebraker
# Name: aws_fix_dual_nic_routing.sh
# Requirement:
# -Two interfaces assigned in the AWS control panel and a private ip for each
# -Both interfaces should appear when typing ifconfig
# 
# Description:
# Script will:
# 1. Generate your new static /etc/network/interfaces
# 2. Restart networking
# 3. If you get an error then at this point you need to "stop network-manager" (ssh will probably flap to the other ip)
# 4. If ssh flapped then run the script again and ip route table will be set up properly

########################################
function print_status ()
{
    echo -e "\x1B[01;34m[*]\x1B[0m $1"
}

function print_good ()
{
    echo -e "\x1B[01;32m[*]\x1B[0m $1"
}

function print_error ()
{
    echo -e "\x1B[01;31m[*]\x1B[0m $1"
}

function print_notification ()
{
  echo -e "\x1B[01;33m[*]\x1B[0m $1"
}
function printline() {
hr=---------------------------------------------------------------\
----------------------------------------------------------------
printf '%s\n' "${hr:0:${COLUMNS:-$(tput cols)}}"
}
function proceed_if_root()
{
#Make sure only root can run our script
        if [[ $EUID -ne 0 ]]; then
           print_error "This script must be run as root" 1>&2
           exit 1
        fi
}
declare -i state_ok=0
declare -i state_warning=1
declare -i state_critical=2
declare -i state_unknown=3
declare -i state_dependent=4

# Make sure ip and egrep commands are valid
if [[ ! -x "$(type -p ip 2>/dev/null)" ]]; then
	echo "ERROR: 'ip' not executable"
	exit ${state_unknown}
fi

if [[ ! -x "$(type -p egrep 2>/dev/null)" ]]; then
	echo "ERROR: 'egrep' not executable"
	exit ${state_unknown}
fi


function system_is_link_up () {
  #determines if interface is up
  iface=$1
  ip link show dev ${iface} >&/dev/null
  if [ "$?" != "0" ]; then
    echo "CRITICAL - interface '${iface}' does NOT EXIST!"
    exit 2
  fi
  ip addr show dev ${iface} 2>/dev/null |  egrep "[[:space:]]${iface}:.*(,|<)UP(,|>)"  >&/dev/null
  if [ "$?" != "0" ]; then
    echo "CRITICAL - interface '${iface}' is not up"
    exit 2
  fi
  print_good "OK - ${iface} is configured and is UP"
}
function system_print_ip_for_interface {
  # returns the  IP assigned to interface passed
  # ex: system_print_ip_for_interface eth0
  echo $(ifconfig $1 | awk -F: '/inet addr:/ {print $2}' | awk '{ print $1 }')
}
function system_print_broadcast_for_interface {
  # returns the  IP assigned to interface passed
  # ex: system_print_ip_for_interface eth0
  echo $(/sbin/ifconfig $1 | grep 'inet addr:' | cut -d: -f3 | awk '{ print $1}')
}
function system_print_mask_for_interface {
  # returns the  IP assigned to interface passed
  # ex: system_print_ip_for_interface eth0
  echo $(/sbin/ifconfig $1 | grep 'inet addr:' | cut -d: -f4 | awk '{ print $1}')
}
function system_dns_search_domain {
  # returns the primary IP assigned to eth0
  echo $(grep "search" /etc/resolv.conf | cut -d' ' -f2)
}

system_is_link_up "eth0"
system_is_link_up "eth1"



proceed_if_root

#eth0
eth0IP=`system_print_ip_for_interface "eth0"`
eth0Broadcast=`system_print_broadcast_for_interface "eth0"`
eth0Mask=`system_print_mask_for_interface "eth0"`

#eth1
eth1IP=`system_print_ip_for_interface "eth1"`
eth1Broadcast=`system_print_broadcast_for_interface "eth1"`
eth1Mask=`system_print_mask_for_interface "eth1"`
eth1route=$(ip route | grep "default" |  cut -d " " -f3 | uniq)

#get network
IP=$(ifconfig eth1 | grep Mask | cut -d ':' -f2 | cut -d " " -f1)
Mask=$(ifconfig eth1 | grep Mask | cut -d ':' -f4 | cut -d " " -f1)
IFS=.
IPArray=($IP)
MaskArray=($Mask)
NetArray=()
Start=0
Max=$(( 255 * 255 * 255 * 255 ))
for key in "${!IPArray[@]}";
do
   NetArray[$key]=$(( ${IPArray[$key]} & ${MaskArray[$key]} ))
   Start=$(( $Start + (${NetArray[$key]} << (3-$key)*8) ))
done
IFS=

eth1Network="${NetArray[0]}.${NetArray[1]}.${NetArray[2]}.${NetArray[3]}"

dnsSearchDomain=`system_dns_search_domain`
print_status "eth0 info"
print_notification $eth0IP
print_notification $eth0Broadcast
print_notification $eth0Mask
printline
print_status "eth1 info"
print_notification $eth1IP
print_notification $eth1Broadcast
print_notification $eth1Mask
echo $eth1Network
printline
print_status "dns name servers"
printline
echo "" > /tmp/nameservers.tmp
  # if the user didn't provide a FQDN then just append hostname they provided


for nameserver in $(/bin/egrep \
'\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b' \
/etc/resolv.conf \
| /usr/bin/cut -d: -f2 \
| awk '{ print $2}'); do
printf " %s" "$nameserver" >> /tmp/nameservers.tmp
done

printedNameservers=$(sed ':a;N;$!ba;s/\n/ /g' /tmp/nameservers.tmp)

print_status "dns search domain"
print_notification "${dnsSearchDomain}"
printline
print_status "proposed /etc/network/interfaces file"
cat <<EOF > /tmp/proposed.interfaces
# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
address ${eth1IP}
netmask ${eth1Mask}
network ${eth1Network}
broadcast ${eth1Broadcast}

dns-nameservers${printedNameservers}
dns-search ${dnsSearchDomain}
EOF

cat /tmp/proposed.interfaces

print_status "changing /etc/network/interfaces"
mv /tmp/proposed.interfaces /etc/network/interfaces

printline
print_good "restarting networking"
/etc/init.d/networking restart

print_status "If you got an error that is okay - you need to stop nework manager"
echo "ex: stop network-manager"


##Then to ensure that traffic that arrives on eth1 also exists on eth1:
printline
print_status "creating a new policy routing table entry within the /etc/iproute2/rt_tables"
echo "1 admin" >> /etc/iproute2/rt_tables

print_status "adding entries to our new admin table"
ip route add ${eth1Network} dev eth1 src ${eth1IP} table admin
ip route add default via ${eth1route} dev eth1 table admin

print_status "view of ip rule table before change are applied"
printline
ip rule
printline

print_status "view of routing table before changes are applied"
printline
netstat -rn
printline

print_status "applying the rules on the admin table"
ip rule add from ${eth1IP}/32 table admin
ip rule add to ${eth1IP}/32 table admin
# /sbin/ip rule del from 192.168.0.0/26 table 200

print_status "flushing ip routing cache"
ip route flush cache

print_status "view of ip rule table after change are applied"
printline
ip rule
printline

print_status "view of routing table after changes are applied"
printline
netstat -rn
printline
