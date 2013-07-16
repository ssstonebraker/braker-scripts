#!/bin/sh
#
#
# Name: zombie.bash
# Usage: ./zomebie.bash &
#
# To show zombie processes:  ps aux | awk '{ print $8 " " $2 }' | grep -w Z
#
#
time=${1:-60}
sleep 1 &
exec sleep $time
