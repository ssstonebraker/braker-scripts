#!/bin/bash
#
# Author: Steve Stonebraker
# Date: August 20, 2013
# Name: shred_self.sh
# Purpose: securely self-deleting shell script
#

currentscript=$0

# function that is called when the script exits
function finish {
	echo "shredding ${currentscript}"; shred -u ${currentscript};
}

#whenver the script exits call the function "finish"
trap finish EXIT

#last line of script
echo "exiting script"
