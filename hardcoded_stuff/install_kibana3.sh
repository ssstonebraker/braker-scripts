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


read -p "What is the FQDN of your Elasticsearch server (ex: elastic.example.com) ?" fqdn_es_server


rm -Rf ${path_install}
cd /opt
git clone https://github.com/elasticsearch/kibana


cat << 'EOF' > ${path_install}/config.js
var config = new Settings(
{
  
  elasticsearch: 'http://localhost:9200',
  kibana_index:     "kibana-int",
  modules:          ['histogram','map','pie','table','filtering',
                    'timepicker','text','fields','hits','dashcontrol',
                    'column','derivequeries','trends','bettermap','query',
                    'terms'],
  }
);
EOF

replaceText localhost ${fqdn_es_server} ${path_install}/config.js
replaceText 9200 443 ${path_install}/config.js

cp ${path_install}/dashboards/logstash.json ${path_install}/dashboards/default.json
cd ${path_install}/dashboards
curl -O https://raw.github.com/paulczar/docker-logstash-demo/master/syslog.json
chown -R www-data:www-data ${path_install}


