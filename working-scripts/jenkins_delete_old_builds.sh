#!/bin/bash

# jenkins_delete_old_builds.sh
# Author: Steve Stonebraker
# Date: 8/5/2019
# Description: Deletes any build older than 30 days
# Place in crontab
# @daily /bin/bash -x /root/scripts/jenkins_cleanup.sh > /root/scripts/jenkins_cleanup.log

find /var/lib/jenkins/jobs/*/builds/ -maxdepth 1 -mindepth 1 -mtime +30 -type d -regextype egrep -regex '^.*/[0-9]*$' -exec rm -rfv {} \;