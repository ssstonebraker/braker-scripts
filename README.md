braker-scripts
==============

Scripts written by Steve Stonebraker for Administration

==============

###install_mod_security_2.7.4.sh
This has only been tested on an Ubuntu precise (12.04) server.  This script will:

* Download the source code for Modsecurity version 2.7.4
* Ensure all required prerequisites are installed
* Install ModSecurity to /opt/modsecurity
* Create the recommended folder structure (from the ModSecurity book) under /opt/modsecurity
* Enable the relevant Apache Modules

     
###install_mod_security_audit_console.sh
Install the jwall audit console for modsecurity on an Ubuntu 12.04 machine


###cidr_to_ipset.sh
Converts a text file with a list of CIDR ip blocks in to a saved hashset.  

Sample lists of CIDR blocks available for US, Great Britian, Spain, Italy, and France

###install_ipset_rules.sh
Performs the following:

1. Download your compressed rule hashes from an s3 bucket
2. Decompress
3. Install ipset
4. Add rules
5. Modify iptables to use the new rules

###ubuntu_change_hostname.sh
Easily change your hostname on any debian based distribution

###Security information and event management

* install_aws_elasticsearch_cluster_node.sh
* upgrade_logstash_to_1.1.13.sh
* install_kibana3.sh
