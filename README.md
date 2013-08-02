braker-scripts
==============

Scripts written by Steve Stonebraker for Administration

==============

###ubuntu_change_hostname.sh
Easily change your hostname on any debian based distribution


###install_ipset_rules.sh
Performs the following:

1. Download your compressed rule hashes from an s3 bucket
2. Decompress
3. Install ipset
4. Add rules
5. Modify iptables to use the new rules

###check_elastic_redis_running.sh

* Ensure that Elastic Search and Redis are running
* Start them if they are not running

###install_mod_security_2.7.4.sh
This has only been tested on an Ubuntu precise (12.04) server.  This script will:

* Download the source code for Modsecurity version 2.7.4
* Ensure all required prerequisites are installed
* Install ModSecurity to /opt/modsecurity
* Create the recommended folder structure (from the ModSecurity book) under /opt/modsecurity
* Enable the relevant Apache Modules

     
###install_mod_security_audit_console.sh
Install the jwall audit console for modsecurity on an Ubuntu 12.04 machine
