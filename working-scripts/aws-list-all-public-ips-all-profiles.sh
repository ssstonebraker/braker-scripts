#!/bin/bash
# Author: Steve Stonebraker
# Date: 2020-06-19
# Name: aws-list-all-public-ips-all-profiles.sh
# Purpose: Outputs a list of public IP Addresses used by the ec2 instances across all accounts specified in your ~/.aws/config file


OUTDIR="${PWD}/output_all_pulic_ips"
echo $OUTDIR

[ ! -d ./${OUTDIR} ] && /bin/mkdir ${OUTDIR}  || /bin/rm -f ./${OUTDIR}/*

aws_profiles=$( \
        grep '\[profile' ~/.aws/config \
        | awk '{sub(/]/, "", $2); print $2}' \
)

# Iterate through all profiles in ~/.aws/config
for profile in ${aws_profiles}
do
    echo "[*] - Processing profile [$profile]"
    aws ec2 describe-instances   --profile ${profile} --query "Reservations[*].Instances[*].PublicIpAddress"   --output=text > ${OUTDIR}/${profile}_.txt
    echo file written to ${OUTDIR}/${profile}_.txt
done

    echo "[*] - Processing default instance"
# Don't forget about the default instance
     profile="default"
     aws ec2 describe-instances   --query "Reservations[*].Instances[*].PublicIpAddress"   --output=text > ${OUTDIR}/${profile}_.txt
     echo "file written to ${OUTDIR}/${profile}_.txt"

echo "[*] - combining all output"

cat ${OUTDIR}/*.txt | sort | uniq > ${OUTDIR}/all_public_ips.txt
echo "[*] -  located at ${OUTDIR}/all_public_ips.txt"
