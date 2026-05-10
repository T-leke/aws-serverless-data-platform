output "source_bucket_id" {
  value = aws_s3_bucket.source.id
}

output "source_bucket_name" {
  value = aws_s3_bucket.source.bucket
}

output "source_bucket_arn" {
  value = aws_s3_bucket.source.arn
}

output "bronze_bucket_name" {
  value = aws_s3_bucket.bronze.bucket
}

output "bronze_bucket_arn" {
  value = aws_s3_bucket.bronze.arn
}

output "silver_bucket_name" {
  value = aws_s3_bucket.silver.bucket
}

output "silver_bucket_arn" {
  value = aws_s3_bucket.silver.arn
}

output "gold_bucket_name" {
  value = aws_s3_bucket.gold.bucket
}

output "gold_bucket_arn" {
  value = aws_s3_bucket.gold.arn
}