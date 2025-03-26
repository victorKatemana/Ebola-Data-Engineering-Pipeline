import os
import logging
from google.cloud import storage
from dotenv import load_dotenv

# Set up logging
logging.basicConfig(level=logging.INFO)

# Load environment variables from .env file
load_dotenv()

# GCS configuration
bucket_name = os.getenv('BUCKET_NAME')  # This will get the bucket name from your .env file
local_file_path = os.getenv('LOCAL_FILE_PATH')  # Local file to upload
destination_blob_name = os.getenv('DESTINATION_BLOB_NAME')  # The name in GCS

# Log the loaded environment variables for debugging
logging.info(f"Bucket Name: {bucket_name}")
logging.info(f"Local File Path: {local_file_path}")
logging.info(f"Destination Blob Name: {destination_blob_name}")

try:
    # Initialize GCS client
    storage_client = storage.Client()
    logging.info("GCS client initialized successfully.")

    # Get the GCS bucket
    bucket = storage_client.get_bucket(bucket_name)
    logging.info(f"Bucket {bucket_name} retrieved successfully.")

    # Create a blob object (represents the file in GCS)
    blob = bucket.blob(destination_blob_name)
    logging.info(f"Blob object created for {destination_blob_name}.")

    # Upload the file to GCS
    logging.info(f"Starting upload of {local_file_path} to GCS...")
    blob.upload_from_filename(local_file_path)
    logging.info(f"File {local_file_path} uploaded to {bucket_name}/{destination_blob_name}.")

except Exception as e:
    logging.error(f"An error occurred during the upload process: {e}")
