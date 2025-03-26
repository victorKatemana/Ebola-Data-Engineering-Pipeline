import os
import logging
from google.cloud import storage
from dotenv import load_dotenv

# Enable logging
logging.basicConfig(level=logging.INFO)

# Load environment variables
load_dotenv()

# Check if the credentials file exists
credentials_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
if not os.path.exists(credentials_path):
    logging.error(f"Credentials file not found: {credentials_path}")
    exit(1)

# Check if the dataset file exists
local_file_path = os.getenv("LOCAL_FILE_PATH")
if not os.path.exists(local_file_path):
    logging.error(f"Local file not found: {local_file_path}")
    exit(1)

# Retrieve other environment variables
bucket_name = os.getenv("BUCKET_NAME")
destination_blob_name = os.getenv("DESTINATION_BLOB_NAME")

# Google Cloud Storage Upload
client = storage.Client()
bucket = client.bucket(bucket_name)
blob = bucket.blob(destination_blob_name)

logging.info(f"Uploading {local_file_path} to {bucket_name}/{destination_blob_name}...")

try:
    blob.upload_from_filename(local_file_path)
    logging.info("Upload successful!")
except Exception as e:
    logging.error(f"Upload failed: {e}")
    exit(1)
