#!/bin/bash
#
# Author: Steve Stonebraker
# Date 2020-06-16
# Script Name: generate_lambdaguard_report_all_profiles.sh
# Raw location: https://raw.githubusercontent.com/ssstonebraker/braker-scripts/master/working-scripts/generate_lambdaguard_report_all_profiles.sh
#
#
# Description:
# This script will generate a lambdaguard report for all profiles defined in ~/.aws/config
#

OUTDIR="${PWD}/report"
echo "Output dir: ${OUTDIR}"

# remove existing output directory 
if [ -d ./"${OUTDIR}" ]; then 
   /bin/rm -f ./"${OUTDIR}"/* 2>/dev/null
fi

# create new output directory
/bin/mkdir "${OUTDIR}" 2>/dev/null

# Place all AWS Profiles in to an array
aws_profiles=$( \
        egrep '\[profile' ~/.aws/config \
        | awk '{sub(/]/, "", $2); print $2}' \
)

# Add default profile if defined as [default] in ~/.aws/config
grep '\[default' ~/.aws/config >/dev/null &&  aws_profiles=("${aws_profiles[@]}" "default")


# Create lambdaguard report
gen_report () {
mkdir -p "$OUTPUT"
#echo " path: $OUTPUT"
[ ! -d "$OUTPUT" ] && echo "$OUTPUT does not exist... exiting" && exit
lambdaguard --verbose --function "$ARN" \
--profile "$PROFILE" \
--output "$OUTPUT"
}

# set some global variables based on profile
set_vars () {
name_lambda=$1
name_profile=$2
#debug
#echo "name_lambda=${name_lambda}"
#echo "name_profile=${name_profile}"
ACCOUNTID=$(aws sts get-caller-identity --profile "${name_profile}" --query Account --output text)
ARN="arn:aws:lambda:us-east-1:${ACCOUNTID}:function:${name_lambda}"
#debug
#echo "ARN: $ARN"
PROFILE="${name_profile}"
OUTPUT="${OUTDIR}/${name_profile}-${name_lambda}"
}


# Iterate through all profiles in ~/.aws/config
# Note: this will not proccess the defa
for profile in ${aws_profiles[@]}
do
    export name_profile="${profile}"
    echo "[*] - [$profile] - Downloading all lambdas"
    aws lambda list-functions --profile "${profile}" --query 'Functions[*].[FunctionName]' --output text | tr '\r\n' ' ' > "${OUTDIR}"/"${profile}"_.txt
    toprocess="${OUTDIR}/${profile}_.txt"
    echo "[*] - [$profile] - Lambda list written to ${OUTDIR}/${profile}_.txt"
    for name in $(cat ${toprocess}); do
     echo "[*] - [${profile}] - Generating LambdaGuard report for lambda [$name]"
     set_vars "${name}" "${name_profile}"
      gen_report
    done
done

