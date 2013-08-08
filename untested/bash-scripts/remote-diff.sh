#!/bin/bash
#
# Author: Steve Stonebraker
# Title: remote-diff.sh
# Based on: https://gist.github.com/beryllium/5157006
# Description: This will colordiff two files over ssh
#
#

########################################
#source another file (it has functions we use)

checkProgramIsInEnvironment colordiff

if [ -z "$1" -o -z "$2" -o -z "$3" ]
then
  echo "Usage: remote-diff.sh [user@]host1 [user@]host2 path_to_file"
  echo ""
  echo "Note: If you need to specify a valid key or optional username for the host,"
  echo "      you are encouraged to add the host configuration to your ~/.ssh/config file."
  exit 1
fi
 
#Inspired by a post on StackOverflow: http://serverfault.com/a/59147/114862
colordiff <(ssh "$1" cat "$3") <(ssh "$2" cat "$3")