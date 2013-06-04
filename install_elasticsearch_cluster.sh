#!/bin/bash
#
# Name: install_elasticsearch.sh
# Author: Steve Stonebraker
# Date: 6/4/2013
# Purpose: Install elastic search 0.20.5 on Ubuntu 12.04 LTS for deployment in an AWS Cluster
# Description: This will set up a single node in an elastic search cluster called "logstash"
#
# Usage ./install_elasticsearch_cluster.sh

echo "User Check"
     if [ $(whoami) != "root" ]
          then
               echo "This script must be ran with sudo or root privileges, or this isn't going to work."
		exit 1
          else
               echo "We are root."
     fi

echo "Gathering Info About Your AWS Setup..."
read -p "Each instance you want in the cluster \
should have a tag with key 'elastic-cluster', please \
provide the value of that key (ex:production-logstash, \
mycluster, etc)" aws-tag
read -p "Path on disk (no trailing slash) where you want to store data" edata-location
read -p "Provide IAM provisioned access_key" access_key
read -p "Provide IAM provisioned secret_key" secret_key
read -p "provide region (ex: us-west-2)" aws_region

echo "installing jre headless"
apt-get install -y default-jre-headless

echo "Setting Some Variables:"
CLUSTER_NAME="logstash"
NODE_NAME=$(hostname)
ECONFIG=/etc/elasticsearch/elasticsearch.yml
ECONF=/usr/share/elasticsearch/bin/service/elasticsearch.conf


echo "installing elastic search"
mkdir -p /tmp/src && cd /tmp/src
curl -O "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.20.5.deb"
dpkg -i elasticsearch-0.20.5.deb

echo "Installing elastic search plugins"
/usr/share/elasticsearch/bin/plugin -install mobz/elasticsearch-head
/usr/share/elasticsearch/bin/plugin -install lukas-vlcek/bigdesk/2.0.0
/usr/share/elasticsearch/bin/plugin -install elasticsearch/elasticsearch-cloud-aws/1.4.0

echo "Setting up elastic search service"
curl -L http://github.com/elasticsearch/elasticsearch-servicewrapper/tarball/master | tar -xz
mv *servicewrapper*/service /usr/share/elasticsearch/bin/
rm -Rf *servicewrapper*
/usr/share/elasticsearch/bin/service/elasticsearch install
ln -s `readlink -f /usr/share/elasticsearch/bin/service/elasticsearch` /usr/bin/rcelasticsearch
service elasticsearch start

echo "Add our cluster details to the configuration files"
ES_HEAP_SIZE=$(($(/usr/bin/awk '/MemTotal/{print $2}' /proc/meminfo) / 2))k
echo "ES_HEAP_SIZE=${ES_HEAP_SIZE}" >> /etc/default/elasticsearch
sed -i "s/set\.default\.ES_HEAP_SIZE=.*/set.default.ES_HEAP_SIZE=${ES_HEAP_SIZE}/" ${ECONF}
sed -i "s/# cluster.name:.*/cluster.name: $CLUSTER_NAME/" ${ECONFIG}
sed -i "s/# cluster.name:.*/cluster.name: $NODE_NAME/" ${ECONFIG}


echo "cloud.aws.access_key: $access_key}" >> ${ECONFIG}
echo "cloud.aws.secret_key: ${secret_key}" >> ${ECONFIG}
echo "cloud.aws.region: ${aws_region}" >> ${ECONFIG}
echo "discovery.type: ec2" >> ${ECONFIG}
echo "discovery.ec2.ping.timeout: 30s" >> ${ECONFIG}
echo "discovery.ec2.tag.elastic-cluster: ${aws-tag}" >> ${ECONFIG}
echo "path.data: ${edata-location}" >> ${ECONFIG}

echo "Restart Elastic Search"
service elasticsearch restart

echo "Don't forget to permit TCP 9200-9400 to the hosts in your elasticsearch cluster"