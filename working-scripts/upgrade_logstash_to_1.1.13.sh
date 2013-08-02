#!/bin/bash
#
# Name: upgrade_logstash_to_1.1.13.sh
# Author: Steve Stonebraker
# Date: 7/30/2013
# Purpose: Upgrade logstash to 1.1.13 on Ubuntu 12.04 LTS 
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
stop logstash-indexer
cd /opt/logstash
curl -O "https://logstash.objects.dreamhost.com/release/logstash-1.1.13-flatjar.jar"
rm /opt/logstash/logstash.jar
ln -s /opt/logstash/logstash-1.1.13-flatjar.jar /opt/logstash/logstash.jar
start logstash-indexer