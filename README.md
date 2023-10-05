braker-scripts
==============

Scripts written by Steve Stonebraker for Administration & Simluations

==============

## AWS SCRIPTS
Scripts written for interaction with the AWS cli

### aws-find-missing-accounts-in-credentials-file.sh
print accounts that exist remotely but do not exist in ~/.credentials file

### aws_fix_dual_nic_routing.sh
* Add two network interface in ubuntu 12.04 in aws and route traffic properly to either ip
* Scope: Amazon EC2 Attach Elastic Network Interface (VPC)

Automates this manual process (from 4-10)

1.  Start AMI in VPC
2.  After boot attach secondary nic
3.  Ensure both nic's have an external IP associated with it
4.  configure new /etc/network/interfaces
5.  restart networking
6.  stop network-manger
7.  ssh back in (ssh will flip to the other elastic ip)
8.  add new ip route
9.  flush ip route table
10. restart networking

More details at http://brakertech.com/aws-add-two-network-interfaces-in-ubuntu-12-04-precise/

### aws-list-subnets-all-profiles.sh
print subnets from all vpcs across all profiles to a txt file

### aws-list-all-public-ips-all-profiles.sh
output all ec2 public IPs from all profiles in ~/.aws/config

### aws-route53-saml2aws-all-account-backup.sh
Exports all route53 zones across all AWS accounts

### aws-s3-dl-list-uris-multithread.py
Downloads a list of s3 objects (user provided) using multithreading (100 concurrent downloads at a time)

### aws-s3-find-public-objects-in-s3-buckets.py
If you provide the file with a list of s3 buckets, it will enumerate every object in each bucket and output which objects are publicy accessible.

### generate_lambdaguard_report_all_profiles.sh
Generates a lambdaguard report for all profiles listed in ~/.aws/config


## Perl
### ddos_ntp.pl
NTP Reflection and Amplification attack simlator

Requires:
* Net::RawIP
* System capable of sending raw packets


### listmodules.pl
Displays currently installed perl modules

## ModSecurity

### install_mod_security_2.7.4.sh
This has only been tested on an Ubuntu precise (12.04) server.  This script will:

* Download the source code for Modsecurity version 2.7.4
* Ensure all required prerequisites are installed
* Install ModSecurity to /opt/modsecurity
* Create the recommended folder structure (from the ModSecurity book) under /opt/modsecurity
* Enable the relevant Apache Modules

     
### install_mod_security_audit_console.sh
Install the jwall audit console for modsecurity on an Ubuntu 12.04 machine


### Security information and event management

* install_aws_elasticsearch_cluster_node.sh
* upgrade_logstash_to_1.1.13.sh
* install_kibana3.sh

## Other


### add_current_shell_and_path_to_crontab.sh
Will add the ${PATH} of the current shell to the crontab

### cidr_to_ipset.sh
Converts a text file with a list of CIDR ip blocks in to a saved hashset.  

Sample lists of CIDR blocks available for US, Great Britain, Spain, Italy, and France


### fwtest_solariburst_domains.sh
Performs a nslookup on all Solariburst malicious domains
Purpose: To test Endpoint Detection Response and Network Monitoring Software

### install_ipset_rules.sh
Performs the following:

1. Download your compressed rule hashes from an s3 bucket
2. Decompress
3. Install ipset
4. Add rules
5. Modify iptables to use the new rules

### ip_lookup_from_list.sh
Will perform nslookup on a list of FQDNs in a file (provided via an argument)

### ubuntu_change_hostname.sh
Easily change your hostname on any debian based distribution

### shred_self.sh
Example script will shred itself once ran

### shred_self_and_dir.sh
Example script will shred itself and the current directory (if empty)

### use_ssl_decrypt_cert_on_cli.sh
This allows you to use a custom ssl decrypt cert from the keystore on the cli.  

For use with Zscaler/ Palo Alto Global Protect SSL decryption.
