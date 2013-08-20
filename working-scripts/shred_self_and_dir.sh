#!/bin/bash
#
# Author: Steve Stonebraker
# Date: August 20, 2013
# Name: shred_self_and_dir.sh
# Purpose: securely self-deleting shell script, delete current directory if empty
# http://brakertech.com/self-deleting-bash-script

#set some variables
currentscript=$0
currentdir=$PWD

#export variable for use in subshell
export currentdir

# function that is called when the script exits
function finish {
    #securely shred running script
	echo "shredding ${currentscript}"
    shred -u ${currentscript};

    #if current directory is empty, remove it    
    if [ "$(ls -A ${currentdir})" ]; then
       echo "${currentdir} is not empty!"
    else
        echo "${currentdir} is empty, removing!"
        rmdir ${currentdir};
    fi

}

#whenver the script exits call the function "finish"
trap finish EXIT

#last line of script
echo "exiting script"
