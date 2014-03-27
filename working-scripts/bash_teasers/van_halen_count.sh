#!/bin/bash
#
# Script: van_halen_count.sh
#
# Author: Steve Stonebraker
# Date: 3-27-2013
# Desc: Totals the number of times "David Lee Roth" or "Sammy Hagar"
#       appear on the Jellyvision employee bio pages
#
#

# Limit concurrent curl instances
LIMIT=40

employees=/tmp/employees

count_string_in_file () {
	result=$(strings /tmp/output | grep -i "$1" | wc -l)
	echo "${1}: ${result}" 
}

# Parse Employee URLs
curl --silent http://www.jellyvision.com/team/ | egrep -o "http:\/\/www\.jellyvision\.com\/team\/([^\/]+)\/" > ${employees}

# Cut all occurances of david or sammy from each employees bio page
tail -n +5 ${employees} | xargs -n 1 -P $LIMIT -I{} bash -c "curl --silent {} | egrep -o -i 'david lee roth|sammy hagar' " > /tmp/output

echo "The Right Answer Totals:"
count_string_in_file "David"
count_string_in_file "Sammy"

