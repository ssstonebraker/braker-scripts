#!/bin/bash
#
# Name: aws-find-missing-accounts-in-credentials-file.sh
# Purpose: Compare accounts found in AWS organization with those in ~/.aws/credentials
# Author: Steve Stonebraker
# Date: 08-25-2021
#

function printline { hr=----------------------------------------------------------------------------------------------------
printf '%s\n' "${hr:0:${COLUMNS:-$(tput cols)}}"
}
# remove tmp files if found
AWS_REMOTE_ALL_ACCTS=/tmp/aws_remote_all_accts.txt
AWS_REMOTE_ALL_ACCTS_WITH_LABEL=/tmp/aws_remote_all_accts_with_label.txt
AWS_LOCAL_FILE_ACCTS=/tmp/all_from_local_creds.txt
[ -f "$AWS_LOCAL_FILE_ACCTS" ] && rm -f "$AWS_LOCAL_FILE_ACCTS"
[ -f "$AWS_REMOTE_ALL_ACCTS" ] && rm -f "$AWS_REMOTE_ALL_ACCTS"
[ -f "$AWS_REMOTE_ALL_ACCTS_WITH_LABEL" ] && rm -f "$AWS_REMOTE_ALL_ACCTS_WITH_LABEL"

if [ ! -f ~/.aws/credentials ]; then
    echo "~/.aws/credentials file not found!"
    exit 0
fi

# Generate list of accounts from local ~/.aws/credentials file
awk -F: '{ print $5 }' ~/.aws/credentials | grep -v "^$" | sort | uniq > "$AWS_LOCAL_FILE_ACCTS"

# Generate list of accounts from your organization
aws organizations list-accounts --output text --query 'Accounts[?Status==`ACTIVE`][Id,Name]' | \
awk '{ print $1 }' | sort  > "$AWS_REMOTE_ALL_ACCTS"

# Generate list of accounts from your organization with acct label
aws organizations list-accounts --output text --query 'Accounts[?Status==`ACTIVE`][Id,Name]' | \
awk '{ print $1","$2 }' | sort -t, -k2 > "$AWS_REMOTE_ALL_ACCTS_WITH_LABEL"

# diff
echo "Profiles that do not exist locally"
printline
aws_profiles=$(diff "$AWS_REMOTE_ALL_ACCTS" "$AWS_LOCAL_FILE_ACCTS" | egrep ">|<" | awk '{ print $2 }' | sort)
for profile in ${aws_profiles}
do
 grep "${profile}" "$AWS_REMOTE_ALL_ACCTS_WITH_LABEL"
done

