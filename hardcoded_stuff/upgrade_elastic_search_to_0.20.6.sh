#!/bin/bash
#
# Name: upgrade_elastic_search_to_0.20.6.sh
# Author: Steve Stonebraker
# Date: 7/30/2013
# Purpose: Upgrade elastic search 0.20.6 on Ubuntu 12.04 LTS 
#
# Usage ./install_elasticsearch.sh
echo "User Check"
     if [ $(whoami) != "root" ]
          then
               echo "This script must be ran with sudo or root privileges, or this isn't going to work."
		exit 1
          else
               echo "We are root."
     fi
service elasticsearch stop
curl -O "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.20.6.deb"
dpkg -i elasticsearch-0.20.6.deb
service elasticsearch stop
service elasticsearch start