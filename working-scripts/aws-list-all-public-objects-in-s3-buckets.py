# place all bucket names, one per line in a file called bucket_names.txt
# run the script (the script assumes you are using the default aws profile)
# all public objects will be written to a file called public-objects.txt

import boto3
import os
import threading

# Function to check if an S3 object is public
def is_public(bucket_name, key):
    try:
        acl = s3.ObjectAcl(bucket_name, key)
        grants = acl.grants
        for grant in grants:
            grantee = grant["Grantee"]
            if "URI" in grantee and grantee["URI"] == "http://acs.amazonaws.com/groups/global/AllUsers":
                return True
        return False
    except Exception as e:
        print(f"Error checking ACL for s3://{bucket_name}/{key}: {str(e)}")
        return False

# Function to scan a bucket for public objects
def scan_bucket(bucket_name):
    try:
        print(f"Scanning bucket: {bucket_name}")
        bucket = s3.Bucket(bucket_name)
        for obj in bucket.objects.all():
            if is_public(bucket_name, obj.key):
                print(f"Found public object: s3://{bucket_name}/{obj.key}")
                with open("public-objects.txt", "a") as f:
                    f.write(f"s3://{bucket_name}/{obj.key}\n")
    except Exception as e:
        print(f"Error scanning bucket {bucket_name}: {str(e)}")

# Load AWS default profile from ~/.aws/config
session = boto3.Session(profile_name='default')
s3 = session.resource('s3')

# Read bucket names from a file
bucket_list_file = 'bucket_names.txt'  # Replace with the path to your input file
with open(bucket_list_file, 'r') as f:
    bucket_names = [line.strip() for line in f]

# Create and start threads for each bucket
threads = []
for bucket_name in bucket_names:
    thread = threading.Thread(target=scan_bucket, args=(bucket_name,))
    threads.append(thread)
    thread.start()

# Wait for all threads to finish
for thread in threads:
    thread.join()

print("Scanning completed.")
