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

######################################
# Variable Setup
# Limit concurrent curl instances
LIMIT=10

# Tmp file for employee urls and grep results
EMPLOYEES=/tmp/employees
BAND_MEMBERS=/tmp/output
######################################

#############
# Functions #
#############

###############################################
# Count the occurances of band member in file #
###############################################
count_string_in_file () {
  result=$(strings ${BAND_MEMBERS} | \
    grep -i "$1" | wc -l)

  echo "${1}: ${result}" 
}

#######################
# Parse Employee URLs #
#######################
parse_employee_urls () {
  echo "Parsing employee urls..."
  curl --silent http://www.jellyvision.com/team/ | \
  egrep -o \
  "http:\/\/www\.jellyvision\.com\/team\/([^\/]+)\/" \
  > ${EMPLOYEES}
}

############################################################
# Cut all occurances of David Lee Roth or Sammy Hagar from #
# each employee bio page and place in ${BAND_MEMBERS} file #
#                                                          #
# Concurrent curl connections are limited by ${LIMIT}      #
############################################################
get_band_members () {
  echo "Inspecting each bio page for correct answer..."
  tail -n +5 ${EMPLOYEES} | \
  xargs -n 1 -P $LIMIT -I{} bash -c \
  "curl --silent {} | egrep -o -i 'david lee roth|sammy hagar' " \
  > ${BAND_MEMBERS}
}

########################
# MAIN EXECUTION POINT #
########################
parse_employee_urls
get_band_members

echo "The Right Answer Totals:"
count_string_in_file "David"
count_string_in_file "Sammy"
