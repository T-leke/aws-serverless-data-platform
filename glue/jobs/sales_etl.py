import sys
from awsglue.utils import getResolvedOptions
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, current_date, input_file_name, sum, count, avg

args = getResolvedOptions(
    sys.argv,
    [
        "JOB_NAME",
        "BUCKET_NAME",
        "SOURCE_KEY",
        "BRONZE_BUCKET",
        "SILVER_BUCKET",
        "GOLD_BUCKET"
    ]
)

source_bucket = args["BUCKET_NAME"].strip()
source_key = args["SOURCE_KEY"].strip()
bronze_bucket = args["BRONZE_BUCKET"].strip()
silver_bucket = args["SILVER_BUCKET"].strip()
gold_bucket = args["GOLD_BUCKET"].strip()

spark = SparkSession.builder.appName("sales-transactions-etl").getOrCreate()

raw_path = f"s3://{source_bucket}/{source_key}"
bronze_path = f"s3://{bronze_bucket}/transactions/"
silver_path = f"s3://{silver_bucket}/transactions/"
gold_path = f"s3://{gold_bucket}/daily_sales_summary/"

print(f"RAW PATH: {raw_path}")
print(f"BRONZE PATH: {bronze_path}")
print(f"SILVER PATH: {silver_path}")
print(f"GOLD PATH: {gold_path}")

df_raw = (
    spark.read
    .option("header", "true")
    .csv(raw_path)
)

df_bronze = (
    df_raw
    .withColumn("ingestion_date", current_date())
    .withColumn("source_file_name", input_file_name())
)

df_bronze.write.mode("overwrite").parquet(bronze_path)

df_silver = (
    df_bronze
    .dropDuplicates(["transaction_id"])
    .withColumn("quantity", col("quantity").cast("int"))
    .withColumn("unit_price", col("unit_price").cast("double"))
    .withColumn("transaction_date", col("transaction_date").cast("date"))
    .filter(col("transaction_id").isNotNull())
    .filter(col("customer_id").isNotNull())
    .filter(col("quantity") > 0)
    .filter(col("unit_price") > 0)
)

df_silver.write.mode("overwrite").parquet(silver_path)

df_gold = (
    df_silver
    .withColumn("line_total", col("quantity") * col("unit_price"))
    .groupBy("transaction_date", "country")
    .agg(
        count("transaction_id").alias("total_transactions"),
        sum("line_total").alias("total_revenue"),
        avg("line_total").alias("average_order_value")
    )
)

df_gold.write.mode("overwrite").parquet(gold_path)