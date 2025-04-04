# Use Python as the base image
FROM python:3.9

# Set working directory inside the container
WORKDIR /app

# Install required Python packages
RUN pip install --upgrade pip
RUN pip install google-cloud-storage python-dotenv

# Copy project files into the container
COPY . .

# Copy the GCP credentials to the container
COPY secrets/ebola-data-pipeline-secret.json /app/ebola-data-pipeline-secret.json

# Copy the CSV file into the container
COPY dataset/ebola_data_db_format.csv /app/dataset/ebola_data_db_format.csv

# Set environment variable for authentication
ENV GOOGLE_APPLICATION_CREDENTIALS="/app/ebola-data-pipeline-secret.json"

# Command to execute the script
CMD ["python", "upload_to_gcs.py"]
