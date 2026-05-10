output "raw_bucket_name" {
  value = module.s3_data_lake.raw_bucket_name
}

output "bronze_bucket_name" {
  value = module.s3_data_lake.bronze_bucket_name
}

output "silver_bucket_name" {
  value = module.s3_data_lake.silver_bucket_name
}

output "gold_bucket_name" {
  value = module.s3_data_lake.gold_bucket_name
}

output "lambda_function_name" {
  value = module.lambda_validator.lambda_function_name
}

output "state_machine_arn" {
  value = module.step_functions.state_machine_arn
}

