import json
import boto3
import urllib.parse
import os

s3 = boto3.client("s3")
stepfunctions = boto3.client("stepfunctions")

STATE_MACHINE_ARN = os.environ["STATE_MACHINE_ARN"]

EXPECTED_COLUMNS = [
    "transaction_id",
    "customer_id",
    "product_id",
    "transaction_date",
    "quantity",
    "unit_price",
    "country",
    "payment_method"
]


def lambda_handler(event, context):
    print("Received event:")
    print(json.dumps(event))

    record = event["Records"][0]

    bucket = record["s3"]["bucket"]["name"]
    key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])

    print(f"Bucket: {bucket}")
    print(f"Key: {key}")

    if not key.startswith("transactions/"):
        raise Exception(f"Invalid file location: {key}")

    if not key.endswith(".csv"):
        raise Exception(f"Invalid file type: {key}")

    response = s3.get_object(Bucket=bucket, Key=key)
    content = response["Body"].read().decode("utf-8")

    header = content.splitlines()[0].strip().split(",")

    if header != EXPECTED_COLUMNS:
        raise Exception(f"Schema mismatch. Found {header}")

    stepfunctions.start_execution(
        stateMachineArn=STATE_MACHINE_ARN,
        input=json.dumps({
            "bucket": bucket,
            "key": key
        })
    )

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Validation passed and pipeline started",
            "bucket": bucket,
            "key": key
        })
    }
