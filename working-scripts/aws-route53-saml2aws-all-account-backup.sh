#!/bin/bash
###################################################################
# Name: aws-route53-saml2aws-all-account-backup.sh
# Author: Written by Steve Stonebraker (https://www.brakertech.com)
# Date: June 12, 2021
# 
# Description:
#  Exports all route53 zones across all AWS accounts
#
# Requirement:
#  1. This script expects you to be authenticated using saml2aws
#  2. You must have a valid ~/.aws/credential file
###################################################################


#################################################
# Global Variables
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
NOW=$(date +"%FT%H%M%z")
OUTPUT_PATH="${SCRIPTPATH}/route53-backups/zones_$NOW"
VALID_PROFILES="$OUTPUT_PATH/aws_valid_profiles.var"
aws_profiles=$(grep '\[' ~/.aws/credentials | tr -d '[' | tr -d ']')

# Create output path and initialize valid profile file
mkdir -p "$OUTPUT_PATH"; cd "$OUTPUT_PATH" || exit
echo ""> "${VALID_PROFILES}"

#################################################
# Functions
#
# pretty print
print_status () { echo -e "\x1B[01;34m[*]\x1B[0m $1"; }
print_good () { echo -e "\x1B[01;32m[*]\x1B[0m $1"; }
print_error () { echo -e "\x1B[01;31m[*]\x1B[0m $1"; }
print_line () { 
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - 
}

# print output path
print_output_path () {
 print_line
 print_good "OUTPUT PATH: $OUTPUT_PATH"
 print_line
}

# check for cli53
require_cli53 () { 
[ ! -x "$(which cli53)" ] && echo "cli53 required" && exit 1 
}


# check if zones exist in profile
require_zones_exist_in_profile()
{
 profile=$1
 #print_status "checking for zones in ${profile}"
 zones_in_profile=$(cli53 list --profile "${profile}" | tail -n +2 | wc -l)
 if [ "$zones_in_profile" -gt 0 ]; then
  zones_in_profile=`echo $zones_in_profile | sed 's/ *$//g'`
  print_good "[$profile] - [zones: $zones_in_profile]"
  echo "$profile" >> "$VALID_PROFILES"
 else
  print_error "[$profile] - no zones found"
 fi
}

# Validate if AWS profiles are accessible
validate_aws_profiles () {
 print_status "building list of valid profiles..."
 for profile in ${aws_profiles}
  do
  # print_status "validating ${profile} has sts identity"
  IS_VALID_PROFILES=$(aws sts get-caller-identity --no-paginate --profile "${profile}" | grep "Account")

  if [ "$?" -eq 0 ]; then
  # print_good "Validated profile - ${profile}"
    require_zones_exist_in_profile "$profile"
  else
    print_error "Invalid profile - ${profile} ... ignoring"
  fi

  done
 print_status "Profile Validation Complete...proceeding with export"
}

# Export zones from all working profiles
export_zones () {

 valid_profiles=$(grep -v "^$" "${VALID_PROFILES}")

 for profile in ${valid_profiles}
 do
    ZONES_FILE="all-zones_${profile}.bak"
    DNS_FILE="all-dns_${profile}.bak"
    print_line
    print_status "Processing profile [$profile]"
    # print_status "listing all zones for $profile"
    cli53 list --profile "$profile" > "$ZONES_FILE" 2>&1

    # print_status "Creating $DNS_FILE"
    awk '{ print $1 }' "$ZONES_FILE" | tail -n +2 > "$DNS_FILE" 

    # create backup files for each domain
    while read -r line; do
            print_status "exporting $line"
            cli53 export --profile "$profile" --full "$line" > "$line.bak"
    done < "$DNS_FILE"

 done

}

#################################################
# Begin Execution
#
require_cli53
validate_aws_profiles
export_zones
print_output_path
