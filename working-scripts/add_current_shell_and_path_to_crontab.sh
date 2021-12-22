#!/bin/bash
#
# Date: August 22, 2013
# Author: Steve Stonebraker
# File: add_current_shell_and_path_to_crontab.sh
# Description: Add current user's shell and path to crontab
# Source: http://brakertech.com/add-current-path-to-crontab
# Github: https://github.com/ssstonebraker/braker-scripts/blob/master/working-scripts/add_current_shell_and_path_to_crontab.sh

# function that is called when the script exits (cleans up our tmp.cron file)
function finish { [ -e "tmp.cron" ] && rm tmp.cron; }

#whenver the script exits call the function "finish"
trap finish EXIT

########################################
# pretty printing functions
function print_status { echo -e "\x1B[01;34m[*]\x1B[0m $1"; }
function print_good { echo -e "\x1B[01;32m[*]\x1B[0m $1"; }
function print_error { echo -e "\x1B[01;31m[*]\x1B[0m $1"; }
function print_notification { echo -e "\x1B[01;33m[*]\x1B[0m $1"; }
function printline { 
  hr=-------------------------------------------------------------------------------------------------------------------------------
  printf '%s\n' "${hr:0:${COLUMNS:-$(tput cols)}}"
}
####################################
# print message and exit program
function die { print_error "$1"; exit 1; }

####################################
# user must have at least one job in their crontab
function require_gt1_user_crontab_job {
        crontab -l &> /dev/null
        [ $? -ne 0 ] && die "Script requires you have at least one user crontab job!"
}


####################################
# Add current shell and path to user's crontab
function add_shell_path_to_crontab {
	#print info about what's being added
	print_notification "Current SHELL: ${SHELL}"
	print_notification "Current PATH: ${PATH}"

	#Add current shell and path to crontab
	print_status "Adding current SHELL and PATH to crontab \nold crontab:"

	printline; crontab -l; printline

	#keep old comments but start new crontab file
	crontab -l | grep "^#" > tmp.cron

	#Add our current shell and path to the new crontab file
	echo -e "SHELL=${SHELL}\nPATH=${PATH}\n" >> tmp.cron 

	#Add old crontab entries but ignore comments or any shell or path statements
	crontab -l | grep -v "^#" | grep -v "SHELL" | grep -v "PATH" >> tmp.cron

	#load up the new crontab we just created
	crontab tmp.cron

	#Display new crontab
	print_good "New crontab:"
	printline; crontab -l; printline
}

require_gt1_user_crontab_job
add_shell_path_to_crontab
