# Ebola-Data-Engineering-Pipeline
End-to-end data engineering project based on my learnings from the Data Engineering Zoomcamp 2025. This project processes Ebola outbreak data using batch and streaming pipelines, storing it in a cloud-based data warehouse, transforming it for analysis, and visualizing insights via a BI dashboard
## Requirements

Before you start, ensure that you have the following:

- **Docker** installed on your machine.
- **Google Cloud Platform (GCP)** project credentials (Service account JSON key).
- **Python 3.x** environment set up (in the Docker container).
- **.env** file to configure necessary environment variables.

---

## Project Structure

The project is structured as follows:
/Ebola-Data-Engineering-Pipeline ├── Dockerfile ├── upload_to_gcs.py ├── .env ├── dataset/ │ └── ebola_data_db_format.csv ├── secrets/ │ └── ebola-data-pipeline-secret.json


- **Dockerfile**: Defines the Docker image for the pipeline, including required dependencies.
- **upload_to_gcs.py**: The script that uploads the dataset from the local file system to Google Cloud Storage.
- **.env**: Contains configuration variables for the project, such as local file paths, bucket names, and GCP credentials.
- **dataset/**: Folder containing the dataset CSV file to be uploaded.
- **secrets/**: Folder containing the GCP credentials (Service account JSON key).

---

## Setup Instructions

### 1. Clone the Repository

Clone the project repository to your local machine:

```bash
git clone https://github.com/your-repository-link
cd Ebola-Data-Engineering-Pipeline

2. Configure the .env File
The .env file contains important environment variables for the project. It defines paths for local files and the GCS bucket information.

Ensure you have the following variables defined:

# Google Cloud project details
PROJECT_ID=your-google-cloud-project-id
BUCKET_NAME=your-gcs-bucket-name
DATASET_NAME=ebola_dataset_2014

# Path to the local file (to be copied into container)
LOCAL_FILE_PATH=/path/to/your/local/ebola_data_db_format.csv

# Path where the secret key will be inside the container
GOOGLE_APPLICATION_CREDENTIALS=/path/to/your/gcp-credentials.json

# Destination blob name in GCS
DESTINATION_BLOB_NAME=ebola_data_db_format.csv

Important:

Replace your-google-cloud-project-id, your-gcs-bucket-name, and your-gcp-credentials.json with the actual values.

Ensure LOCAL_FILE_PATH points to the correct location of your CSV file.

3. Dockerfile Configuration
The Dockerfile defines the Docker image and the required dependencies to run the pipeline. It installs necessary Python libraries, sets environment variables for authentication, and specifies the command to run the upload script.

# Copy the local dataset file into the container
COPY dataset/ebola_data_db_format.csv /app/dataset/ebola_data_db_format.csv

# Copy the GCP credentials to the container
COPY secrets/ebola-data-pipeline-secret.json /app/ebola-data-pipeline-secret.json

4. Build the Docker Image
Once your .env file is configured, and the Dockerfile is set up, you can build the Docker image.

In the project directory, run the following command to build the image:
 
 docker build -t ebola-data-pipeline .

5. Run the Pipeline
To run the pipeline and upload the dataset to Google Cloud Storage, use the following command:

docker run --rm --env-file .env ebola-data-pipeline
