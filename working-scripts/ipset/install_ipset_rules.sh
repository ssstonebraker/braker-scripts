#!/bin/bash
#
# Name: install_ipset_rules.sh
# Author: Steve Stonebraker
# Date: 7/15/2013
# Purpose: Install ipset rules and set up firewall
# Usage ./install_ipset_rules.sh
#
# User will be prompted to provide AWS Creds and a bucket
# File all_countries.tgz will be downloaded from bucket and extracted
# Extracted file all_countries.ipset will be installed on the host to whitelist those ips
#
# iptables will be updated with the hardcoded values in this script
#
#


########################################
#init script
########################################
cat > /etc/init/iptables.conf << CONFIG_IPTABLES_INIT
description "Starts and stops firewall by restoring ipset and iptables policies."

start on runlevel [2345] or net-device-up IFACE!=lo
stop on runlevel [!2345]
emits firewall

console output 

pre-start script
 test -f /etc/default/ipset && /usr/sbin/ipset -X && /usr/sbin/ipset restore < /etc/default/ipset
 test -f /etc/default/iptables && /sbin/iptables-restore < /etc/default/iptables
 echo "ipset and iptables are running ..."
end script

post-stop script
 /sbin/iptables -F
 /usr/sbin/ipset -X
end script
CONFIG_IPTABLES_INIT
########################################
#iptables rules
########################################
cat > /etc/default/iptables << CONFIG_IPTABLES
*filter
:INPUT ACCEPT [2:240]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [58:6894]
:FWR -
-A INPUT -j FWR
-A FWR -i lo -j ACCEPT

# Accept any established connections
-A FWR -m state --state RELATED,ESTABLISHED -j ACCEPT

#match countries
-A FWR -m set --match-set all_countries src -p tcp -m tcp --dport 80 -j ACCEPT
-A FWR -m set --match-set all_countries src -p tcp -m tcp --dport 443 -j ACCEPT

# log iptables denied calls
-A FWR -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7

# Rejects all remaining connections with port-unreachable errors.
-A FWR -p tcp -m tcp --dport 80 --tcp-flags SYN,RST,ACK SYN -j REJECT --reject-with icmp-port-unreachable
-A FWR -p tcp -m tcp --dport 443 --tcp-flags SYN,RST,ACK SYN -j REJECT --reject-with icmp-port-unreachable
-A FWR -p tcp -m tcp --dport 8443 --tcp-flags SYN,RST,ACK SYN -j REJECT --reject-with icmp-port-unreachable

COMMIT
CONFIG_IPTABLES

########################################
#s3cmd rules
########################################
cat > /root/.s3cfg << CONFIG_S3
[default]
bucket_location = US
cloudfront_host = cloudfront.amazonaws.com
cloudfront_resource = /2010-07-15/distribution
default_mime_type = binary/octet-stream
delete_removed = False
dry_run = False
encoding = UTF-8
encrypt = False
follow_symlinks = False
force = False
get_continue = False
gpg_command = /usr/bin/gpg
gpg_decrypt = %(gpg_command)s -d --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s
gpg_encrypt = %(gpg_command)s -c --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s
gpg_passphrase = obaLApZg7vlt2yzK2dk2
guess_mime_type = True
host_base = s3.amazonaws.com
host_bucket = %(bucket)s.s3.amazonaws.com
human_readable_sizes = False
list_md5 = False
log_target_prefix =
preserve_attrs = True
progress_meter = True
proxy_host =
proxy_port = 0
recursive = False
recv_chunk = 4096
reduced_redundancy = False
send_chunk = 4096
simpledb_host = sdb.amazonaws.com
skip_existing = False
socket_timeout = 10
urlencoding_mode = normal
use_https = True
verbosity = WARNING
CONFIG_S3

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
########################################     
########################################
echo "User Check"
     if [ $(whoami) != "root" ]
          then
               print_error "This script must be ran with sudo or root privileges, or this isn't going to work."
		exit 1
          else
               print_good "We are root."
     fi
########################################
function checkProgramIsInEnvironment
{
	if [ ! -x "$(which $1)" ]; then
		print_status "installing package ${1}"
    	apt-get install -y ${1}
    	if [ $? -eq 0 ]; then
  			print_good "Packages successfully installed."
 			else
  			print_error "Packages failed to install!"
  			exit 1
 		fi
 	else
 		print_status "package ${1} present"
	fi
}
########################################
function install_packages()
{
programs=(s3cmd ipset)
	for program in "${programs[@]}"; do
		checkProgramIsInEnvironment "$program"
	done
}
########################################
function prep_s3cmd()
{
read -p "Provide IAM provisioned access_key: " access_key
read -p "Provide IAM provisioned secret_key: " secret_key
read -p "Provide bucket name: " aws_bucket
echo "access_key = ${access_key}" >> /root/.s3cfg
echo "secret_key = ${secret_key}" >> /root/.s3cfg
}
########################################
function prep_ipset()
{
cd /root
print_status "downloading rules ..."
	s3cmd get s3://${aws_bucket}/all_countries.tgz
	tar xzf all_countries.tgz -C /etc/default
	mv -f /etc/default/all_countries.ipset /etc/default/ipset
}

function protect_files()
{
	print_status "Protecting iptables and ipset defaults..."
	chattr +i /etc/default/iptables
	chattr +i /etc/default/ipset
}
########################################
function shredFile
{
if [ -f "$1" ]; then
	print_status "Shredding ${1}"
	shred -u ${1}
	if [ $? -eq 0 ]; then
 		 print_good "${1} shredded"
 	else
  		print_error "${1} failed to shred!"
  
 	fi
 else
 	print_error "Unable to shred ${1}, file does not exist!"
 fi
}
########################################		
function cleanup_ipset()
{
filesToRemove=(/root/.s3cfg /root/all_countries.tgz)
	for aFile in "${filesToRemove[@]}"; do
		shredFile "$aFile"
	done
}
########################################
######### MAIN EXECUTION POINT #########
########################################
install_packages
prep_s3cmd
prep_ipset
cleanup_ipset
protect_files
start iptables
print_good "iptables and ipset setup complete!"