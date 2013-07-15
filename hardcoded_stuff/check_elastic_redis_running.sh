#!/bin/bash
#
#
# Name: check_elastic_redis_running.sh
# Author: Steve Stonebraker
# Purpose: start elasticsearch and redis if they aren't running
#
#
#
#
#  install to cron instructions:
#  cd /root; curl -O "https://github.com/ssstonebraker/braker-scripts/blob/master/hardcoded_stuff/check_elastic_redis_running.sh";chmod +x /root/check_beaver_size.sh;
#  crontab -l > mycron;echo "*/10 * * * * /root/check_elastic_redis_running" >> mycron;crontab mycron;/bin/rm mycron
#
function check_if_elasticsearch_running () {
        current_script=`basename $0`
        process_name="elasticsearch"
        ps aux | grep "${process_name}" | grep -v 'grep' | grep -v "$current_script"
	
		if [ $? -eq 0 ]; then
		    echo "${process_name} running"
		else
		    echo "${process_name}: not running, starting..."
		    cd /opt/elasticsearch/bin/
		    nohup ./elasticsearch >/dev/null 2>&1
		fi
}
function check_if_redis_running () {
        current_script=`basename $0`
        process_name="redis-server"
        ps aux | grep "${process_name}" | grep -v 'grep' | grep -v "$current_script"
	
		if [ $? -eq 0 ]; then
		    echo "${process_name} running"
		else
		    echo "${process_name}: not running, starting..."
		    if [ -f /var/run/redis_6379.pid ] ; then
				/bin/rm -f /var/run/redis_6379.pid
			fi
		    service redis_6379 start
		fi
}

check_if_elasticsearch_running
check_if_redis_running
sleep 5
check_if_elasticsearch_running
check_if_redis_running
