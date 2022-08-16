#!/bin/bash
#
# Will scan a file containing IPs and domian names
# one per line
# with a full tcp nmap scan (all ports)
# and will perform service enumeration
# output each scan to a separate directory
#
# ./nmapall.sh <filename>

INPUTFILE=$1

if [ -z "${INPUTFILE}" ]; then
 echo "input filename"
 exit
fi


OUTDIR="${PWD}/report"
echo "Output dir: ${OUTDIR}"


for record in $(cat "${INPUTFILE}")
do
   echo "processing ${record}"
   mkdir -p "${OUTDIR}/${record}"
   nmap -Pn -sC -sV -oA "${OUTDIR}/${record}/${record}" -vv -p- "${record}"

done