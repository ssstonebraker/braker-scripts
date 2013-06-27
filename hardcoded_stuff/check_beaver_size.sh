#!/bin/bash -ex

restart_service_mem_ge_x () {
        #
        # Description:Restart service if memory usage is greater than x
        # usage: restart_service_mem_ge_x process_name max_size
        #
        # Example: restart_service_mem_ge_x httpd 1024  (restart httpd if using more than 1024MB of memory
        process_name=$1
        max_size=$2
        start_service_command="$3"

        actual_size=$( /bin/ps aux | /usr/bin/awk "/$process_name/"'{total+=$6}END{print total/1024}' |  /usr/bin/awk '{printf "%.0f\n", $1}' )

        if [ $actual_size -ge $max_size ] ; then
                /bin/echo "${process_name} is currently using ${actual_size}MB, which is greater than or equal to ${max_size}MB"
                /usr/bin/pkill ${process_name}
                $start_service_command
        else
                /bin/echo "${process_name} is currently using ${actual_size}MB, which is less than ${max_size}MB maximum value"
        fi

}

/usr/bin/touch /var/run/logstash_beaver.pid
/bin/chown beaver:beaver /var/run/logstash_beaver.pid

if /bin/ps aux | /bin/grep "[b]eaver" > /dev/null
then
    echo "beaver service is running"
    restart_service_mem_ge_x beaver 512 "service beaver start"
else
    echo "Starting beaver process"

    service beaver start
fi


