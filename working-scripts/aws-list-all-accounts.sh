#!/bin/bash
#
# Name: aws-list-all-accounts.sh
# Purpose: List all aws accounts across all accounts
# Author: Steve Stonebraker
# Date: 08-25-2021
#
aws organizations list-accounts \
--output text \
--query 'Accounts[?Status==`ACTIVE`][Id,Name]' | \
awk '{ print $1","$2 }' | \
sort -t, -k2
