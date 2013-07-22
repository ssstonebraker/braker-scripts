braker-scripts
==============

Scripts written by Steve Stonebraker for Administration

==============

###install_ipset_rules.sh
This script will:
1. Download your compressed rule hashes from an s3 bucket
2. Decompress
3. Install ipset
4. add rules
5. Modify iptables to use the new rules
6. 

###check_elastic_redis_running.sh
This script will ensure elastic search and redis are running

###install_mod_security_2.7.4.sh
This script will install modsecurity version 2.7.4 on an ubuntu precise (12.04) server

####Usage
     curl -s -O https://raw.github.com/ssstonebraker/braker-scripts/master/hardcoded_stuff/install_mod_security_2.7.4.sh
     chmod +x install_mod_security_2.7.4.sh
     ./install_mod_security_2.7.4.sh
     
###install_mod_security_audit_console.sh
This script will install the jwall audit console for modsecurity on an Ubuntu 12.04 machine

####Usage
    curl -s -O https://raw.github.com/ssstonebraker/braker-scripts/master/hardcoded_stuff/install_mod_security_audit_console.sh
    chmod +x install_mod_security_audit_console.sh
    ./install_mod_security_audit_console.sh

###change_hostname.sh
This script will change the hostname of your machine

####Usage
    curl -s -O https://raw.github.com/ssstonebraker/braker-scripts/master/bash-scripts/change_hostname.sh
    chmod +x change_hostname.sh
    ./change_hostname.sh <new_hostname>
