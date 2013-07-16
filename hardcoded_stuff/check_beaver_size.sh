#!/bin/bash -ex
function check_if_beaver_running () {
        current_script=`basename $0`
        process_name="beaver"
        /bin/ps aux | /bin/grep "${process_name}" | /bin/grep -v 'grep' | /bin/grep -v "$current_script"
        
                if [ $? -eq 0 ]; then
                    echo "${process_name} running"
                else
                    echo "${process_name}: not running, starting..."
                    if [ -f /var/run/logstash_beaver.pid ] ; then
                                /bin/rm -f /var/run/logstash_beaver.pid
                        fi
                    service beaver start
                fi
}
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
                service beaver stop
                service beaver start

        else
                /bin/echo "${process_name} is currently using ${actual_size}MB, which is less than ${max_size}MB maximum value"
        fi

}

kill_zombie_processes () {
        /bin/ps -elf | /usr/bin/awk '{print $2 " " $5}' | /bin/grep -w Z | /usr/bin/awk '{print $2}' | xargs kill -9
}

/usr/bin/touch /var/run/logstash_beaver.pid
/bin/chown beaver:beaver /var/run/logstash_beaver.pid

kill_zombie_processes
check_if_beaver_running
restart_service_mem_ge_x beaver 512 "service beaver restart"


