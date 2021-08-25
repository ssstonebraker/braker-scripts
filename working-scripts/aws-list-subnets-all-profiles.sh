#!/bin/bash
# Filename: aws-list-subnets-all-profiles.sh
# Description: print subnets from all vpcs across all profiles to a txt file
# Usage: ./aws-list-subets-all-profiles.sh
# Output: all_subnets.txt
# Author: Steve Stonebraker

aws_profiles=$(
  grep '\[' ~/.aws/credentials \
  |  tr -d \ []
)

for profile in ${aws_profiles}
do
    echo "[*] - Processing profile [$profile]"
    aws ec2 describe-subnets --profile ${profile} | jq -r '.Subnets[]|[.CidrBlock]|@tsv' | sort > subnets_${profile}.txt
done

echo "[*] - Processing default "
aws ec2 describe-subnets | jq -r '.Subnets[]|[.CidrBlock]|@tsv' | sort > subnets_default.txt

echo "[*] - combining all output"

cat subnets*.txt | sort | uniq > all_subnets.txt