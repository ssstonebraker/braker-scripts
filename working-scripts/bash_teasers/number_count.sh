#!/bin/bash
#
# number_count.sh
# Author: Steve Stonebraker
# Description: Between 8000 and 9999 list the numbers that contain integers 0-9 more than once
#


for x in {8000..9999} ; do
	egrep "0{2,4}|1{2,4}|2{2,4}|3{2,4}|4{2,4}|5{2,4}|6{2,4}|7{2,4}|8{2,4}|9{2,4}" <<< "$x" &> /dev/null
	[[ "$?" -eq 0 ]] && echo "number $x has integer 0-9 occuring more than once"

done

