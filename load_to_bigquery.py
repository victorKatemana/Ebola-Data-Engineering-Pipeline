from pyspark.sql import SparkSession
from pyspark.sql.functions import col
from google.cloud import bigquery
import os
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

logger.info("Initializing Spark session...")

spark = SparkSession.builder \
    .appName("Ebola Data Processing") \
    .getOrCreate()

# Configure GCS access
hadoop_conf = spark._jsc.hadoopConfiguration()
hadoop_conf.set("fs.gs.impl", "com.google.cloud.hadoop.fs.gcs.GoogleHadoopFileSystem")
hadoop_conf.set("fs.AbstractFileSystem.gs.impl", "com.google.cloud.hadoop.fs.gcs.GoogleHadoopFS")
hadoop_conf.set("google.cloud.auth.service.account.enable", "true")
hadoop_conf.set("google.cloud.auth.service.account.json.keyfile", os.getenv("GOOGLE_APPLICATION_CREDENTIALS"))

# Read env vars
BUCKET_NAME = os.getenv("BUCKET_NAME")
BQ_DATASET = os.getenv("DATASET_NAME")
BQ_TABLE = os.getenv("BQ_TABLE")

logger.info(f"Using GCS bucket: {BUCKET_NAME}")
logger.info(f"BigQuery dataset: {BQ_DATASET}, table: {BQ_TABLE}")

gcs_file_path = f"gs://{BUCKET_NAME}/ebola_data_db_format.csv"
logger.info(f"Reading data from: {gcs_file_path}")

df = spark.read.option("header", "true").csv(gcs_file_path)
df = df.toDF(*[col.replace(" ", "_").lower() for col in df.columns])
df.printSchema()

logger.info("Writing data to BigQuery...")
df.write \
    .format("bigquery") \
    .option("temporaryGcsBucket", BUCKET_NAME) \
    .option("partitionField", "date") \
    .option("clusteringField", "country") \
    .option("table", f"{BQ_DATASET}.{BQ_TABLE}") \
    .mode("overwrite") \
    .save()

logger.info(f"✅ Data successfully loaded into BigQuery table {BQ_DATASET}.{BQ_TABLE}")
spark.stop()
