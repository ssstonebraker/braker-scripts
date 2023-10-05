import argparse
import os
import threading
import concurrent.futures
import time
import boto3
from urllib.parse import urlparse

# usage
# aws-s3-dl-list-uris-multithread.py <input_file> <output_directory>
# aws-s3-dl-list-uris-multithread.py s3-objects.txt /s3downloads

# Function to download an S3 object and handle exceptions
def download_s3_object(s3_url, output_directory, s3_client):
    try:
        parsed_url = urlparse(s3_url)
        bucket = parsed_url.netloc
        s3_key = parsed_url.path[1:]  # Remove the leading slash

        # Replace "/" with underscores in the S3 key for the local filename
        local_filename = os.path.join(output_directory, bucket, s3_key.replace("/", "_"))

        # Ensure the directory path exists; create if it doesn't
        os.makedirs(os.path.dirname(local_filename), exist_ok=True)

        print(f"Downloading: {s3_url} -> {local_filename}")
        s3_client.download_file(bucket, s3_key, local_filename)
        print(f"Downloaded: {s3_url} -> {local_filename}")
        return True, None
    except Exception as e:
        print(f"Failed to download {s3_url}: {str(e)}")
        return False, str(e)

# Function to process a list of S3 objects
def process_s3_objects(file_path, output_directory):
    s3_client = boto3.client('s3')
    successful_downloads = 0
    failed_downloads = 0

    # Create the output directory with a timestamp
    timestamp = time.strftime("%Y-%m-%d-%H-%M-%S")
    output_directory = os.path.join(output_directory, f"s3-download-output-{timestamp}")
    os.makedirs(output_directory, exist_ok=True)

    # Read the list of S3 objects from the input file
    with open(file_path, 'r') as file:
        s3_object_list = [line.strip() for line in file]

    total_files = len(s3_object_list)
    print(f"Total files to download: {total_files}")

    # Create a ThreadPoolExecutor with a maximum of 100 threads
    with concurrent.futures.ThreadPoolExecutor(max_workers=100) as executor:
        futures = []

        for s3_object in s3_object_list:
            # Submit the download task to the executor
            future = executor.submit(download_s3_object, s3_object, output_directory, s3_client)
            futures.append(future)

        # Wait for all download tasks to complete
        for future in concurrent.futures.as_completed(futures):
            successful, error_msg = future.result()
            if successful:
                successful_downloads += 1
            else:
                failed_downloads += 1

            remaining_files = total_files - successful_downloads - failed_downloads
            print(f"Progress: {successful_downloads} downloaded, {failed_downloads} failed, {remaining_files} remaining")

    # Print summary
    print(f"Total files downloaded: {successful_downloads}")
    print(f"Total failed downloads: {failed_downloads}")
    print(f"Total remaining: {total_files - successful_downloads - failed_downloads}")

    # Write a log file with a timestamp
    log_filename = f"s3_download_log_{timestamp}.txt"
    with open(os.path.join(output_directory, log_filename), 'w') as log_file:
        log_file.write(f"Total files downloaded: {successful_downloads}\n")
        log_file.write(f"Total failed downloads: {failed_downloads}\n")
        log_file.write(f"Total remaining: {total_files - successful_downloads - failed_downloads}\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Download S3 objects from a list in parallel.")
    parser.add_argument("input_file", help="Path to the file containing the list of S3 objects.")
    parser.add_argument("output_directory", help="Output directory for downloaded files.")
    args = parser.parse_args()

    process_s3_objects(args.input_file, args.output_directory)
