#!/bin/bash
#
# Name: install_kibana3.sh
# Author: Steve Stonebraker
# Date: 7/30/2013
# Purpose: install_kibana3.sh on Ubuntu 12.04 LTS 
#
# Usage ./install_kibana3.sh


readonly ourPath="$(dirname $0)"
readonly commonFunctions="$ourPath/common_functions"
if [ ! -e "$commonFunctions" ]; then
       echo "common_functions not found... downloading"
         cd $ourPath
         curl -s -O  "https://raw.github.com/ssstonebraker/braker-scripts/master/common_functions"
fi     
 
if [ -e "$commonFunctions" ]; then
         source "$commonFunctions"
         print_good "loaded commonFunctions file"
 else
         echo "common_functions not found... exiting"
         exit 1;
fi

proceed_if_root
stop kibana
path_install=/opt/kibana
read -p "What is the FQDN of your Elasticsearch server (ex: elastic.explme.com) ?" fqdn_es_server



#rm -Rf install_path
#cd /opt
#git clone https://github.com/elasticsearch/kibana
#chown -R www-data:www-data ${path_install}

replaceText .*elasticsearch:    .* 'http://${fqdn_es_server}:9200', ${path_install}/config.js
cat ${path_install}/config.js
