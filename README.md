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
