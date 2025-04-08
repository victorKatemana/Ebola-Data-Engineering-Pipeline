# Ebola Data Engineering Pipeline

This project demonstrates an end-to-end data engineering pipeline using public Ebola data. It includes data ingestion, storage, transformation, and analytics using tools like Terraform, GCP (BigQuery & GCS), Docker, dbt, and Kestra for orchestration.

## 🚀 Project Structure Overview

This project automates the processing, transformation, and visualization of Ebola outbreak data using modern data engineering tools.

### 🧱 Components

- **Terraform**  
  Provisions all necessary GCP resources:
  - GCS bucket for raw data
  - BigQuery dataset and table for structured storage
  - IAM roles and permissions

- **Kestra**  
  Acts as the orchestrator to automate the workflow from data ingestion to transformation. It runs:
  - A shell command to download the dataset
  - Uploads data to GCS
  - Loads into an external BigQuery table
  - Creates partitioned & clustered materialized table
  - Executes dbt models

- **Docker**  
  Provides containerized alternatives for running:
  - Spark data processing
  - Manual dbt transformation
  - GCS uploads

- **Spark**  
  Cleans and restructures the raw Ebola dataset into a format suitable for analytics.

- **dbt (Data Build Tool)**  
  Applies transformations, defines models, and documents the analytical layer on top of BigQuery.

- **BigQuery**  
  Serves as the central data warehouse:
  - Stores raw and processed data
  - Supports querying and analytics via SQL

- **Looker Studio**  
  Visualizes the final modeled data using:
  - Dashboards
  - Charts and filters for exploring trends by country, indicator, and time

- **Public Data Source**  
  Raw Ebola dataset is pulled from a GitHub repository:
  [Ebola Dataset on GitHub](https://github.com/victorKatemana/Ebola-Data-Engineering-Pipeline)



---

## 🔧 Requirements
- Docker & Docker Compose
- Terraform CLI
- Google Cloud Account & Service Account with permissions
- Python 3.10+ (for Spark/Docker)
- A `.env` file in your root directory:

---

## 📁 Directory Structure

```bash
Ebola-Data-Engineering-Pipeline/
├── dbt/                          # dbt project (models, snapshots, etc.)
│   └── ebola_dbt/               
├── docker/                       # Dockerfiles for spark, upload to GCS, etc.
│   ├── Dockerfile.spark
│   ├── Dockerfile.upload_gcs
├── kestra.yaml                   # Kestra flow definition
├── secrets/                      # GCP credentials file (sa.json)
├── terraform/                    # Terraform infrastructure code
│   ├── main.tf
│   ├── variables.tf              # <-- Update this with your GCP settings
│   └── outputs.tf
├── dataset/                      # Raw Ebola data (e.g., CSV)
├── README.md
```
```

---

## ⚙️ Setup & Configuration

### 1. Clone the Repo
```bash
git clone https://github.com/victorKatemana/Ebola-Data-Engineering-Pipeline.git
cd Ebola-Data-Engineering-Pipeline
```

### 2. Set GCP
Navigate to the `terraform/` folder
```Edit the variables.tf file and:
- Set values for `project_id`, `region`, `bucket_name`, etc.
```

### 3. Apply Terraform
Ensure you are in the terraform folder to initialize/apply the infrastructure:
```bash
cd terraform
terraform init
terraform apply
```
This creates:
- A GCS bucket for raw data
- A BigQuery dataset and external table

---

## ✅ Run the Project with Kestra Orchestration (Recommended)

Kestra automates the pipeline from raw dataset to transformed dbt models.
We use a custom **local-built Kestra Docker image** that includes Python, dbt, and BigQuery support.
This avoids the need for a separate container for dbt CLI.

### 1. Launch Kestra
```bash
cd kestra
docker build -t kestra-with-dbt -f Dockerfile.kestra . #locally built custom Kestra image that comes preconfigured with a Python virtual environment and all necessary dbt packages for BigQuery
docker compose up -d
```

### 2. Access Kestra UI
Visit: [http://localhost:8080](http://localhost:8080)

### 3. Configure KVStore under the ebola namespace
Add the following in Kestra's KVStore UI:
- `GCP_CREDS`: Paste full JSON credentials of GCP service account
- `GCP_PROJECT_ID`: Your GCP project ID
- `BUCKET_NAME`: Name of your GCS bucket
- `BQ_DATASET`: BigQuery dataset name (e.g., `ebola_dataset_2014`)
- `BQ_TABLE`: BigQuery table name (e.g., `ebola_data`)

### 4. Import the Flow
In the UI:
1. Click `+` to create a new flow.
2. Paste contents from `ebola_pipeline` YAML (already provided in `canvas`).
3. Click **Save**.

### 5. Run the Flow
Click `Execute` in the top right corner of the flow. The following will happen:
- Dataset is downloaded from GitHub
- Uploaded to GCS
- BigQuery external & partitioned tables created
- dbt models executed on BigQuery

Logs and artifacts are shown live in the Kestra UI.


## 📊 6. Visualize in Looker Studio

1. Open [Looker Studio](https://lookerstudio.google.com/)
2. Click **"Create" → "Data Source"**
3. Choose **BigQuery** as the connector
4. Authenticate with your Google account
5. Navigate to your project → dataset → table (e.g., `cases_and_deaths_by_country`)
6. Click **Connect**
7. Optionally, customize and build a dashboard with dimensions like:
   - Country
   - Date
   - Confirmed / Probable / Suspected Cases
   - Death counts
8. Link to the current built visuals: https://lookerstudio.google.com/reporting/06628264-c2e5-4292-a637-988be724a5dd/page/q49EF
9. You can also download the visuals from LookerStudioVisuals folder
---

## 🐳 Alternative: Run with Docker Only

You can run each component manually without Kestra:

## ⚙️ Environment Configuration

Before running the pipeline, create a `.env` file in the root of your project with the following content:

```env
# Google Cloud project details
PROJECT_ID=PROJECTID
BUCKET_NAME=ebola_data_bucket_2014
DATASET_NAME=ebola_dataset_2014
BQ_TABLE=ebola_cases

# Path to the local file (to be copied into container)
LOCAL_FILE_PATH=/dataset/ebola_data_db_format.csv

# Path where the secret key will be inside the container
GOOGLE_APPLICATION_CREDENTIALS=/app/ebola-data-pipeline-secret.json

# Destination blob name in GCS
DESTINATION_BLOB_NAME=ebola_data_db_format
```

> 📝 **Note**: Replace paths and credentials with your actual values.

---

You can run each component manually without Kestra:

### 1. Upload to GCS
```bash
docker build -f Dockerfile.upload_gcs -t upload-ebola .
docker run --env-file .env  upload-ebola
```


### 2.  Process with Spark


```bash
docker build -f Dockerfile.spark -t spark-ebola .
docker run --env-file .env spark-ebola
```

### 3. Run dbt

```bash
cd dbt/ebola_dbt
ensure your sa.json is in the ebola_dbt folder
dbt run
```

---

## 🧠 Notes
- The dataset comes from WHO’s 2014 Ebola outbreak data.
- dbt models include logic to clean, aggregate and split cases and deaths.
- Kestra visualizes model lineage and duration in Gantt view.

---
Link to the current built visuals: https://lookerstudio.google.com/reporting/06628264-c2e5-4292-a637-988be724a5dd/page/q49EF
You can also download the visuals from LookerStudioVisuals folder

## 📫 Contact
Victor Katemana — [GitHub](https://github.com/victorKatemana) | [LinkedIn](https://www.linkedin.com/in/victorkatemana)

---
