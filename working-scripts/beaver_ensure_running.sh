#!/bin/bash
#
# Name: beaver_ensure_running.sh
# Author: Steve Stonebraker
# Date: 9/18/2013
# https://raw.github.com/ssstonebraker/braker-scripts/master/working-scripts/beaver_ensure_running.sh
#
# When running in crontab please make sure you set it up like this
#
# SHELL=/bin/bash
# PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# */1 * * * * /bin/bash beaver_ensure_running.sh


START=false
readarray -t PIDS < <(exec pgrep -x beaver)

function stop_beaver {
    /usr/sbin/service beaver stop
    sleep 5s  ## Optionally wait for processes to stop.
    kill -s SIGTERM "${PIDS[@]}" ## Perhaps force another signal to them if it doesn't work with defuncts.
    sleep 5s  ## Optionally wait for processes to stop.
    kill -s SIGKILL "${PIDS[@]}" ## Perhaps force another signal to them if it doesn't work with defuncts.
    START=true
}
if [[ ${#PIDS[@]} -eq 0 ]]; then
    echo "No beaver process was found."
    START=true
elif [[ ${#PIDS[@]} -eq 1 ]]; then
    echo "Processes found: ${PIDS[*]}"
    echo "Only one beaver process found."
    stop_beaver
elif ps -fp "${PIDS[@]}" | fgrep -F '<defunct>' >/dev/null; then
    echo "Processes found: ${PIDS[*]}"
    echo "Defunct beaver process found."
    stop_beaver
else
    echo "Processes found: ${PIDS[*]}"
fi
[[ $START == true ]] && /usr/sbin/service beaver start
