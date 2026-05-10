module "networking" {
  source = "../../modules/networking"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = "10.10.0.0/16"
}

module "s3_data_lake" {
  source = "../../modules/s3-data-lake"

  project_name = var.project_name
  environment  = var.environment
}

module "iam" {
  source = "../../modules/iam"

  project_name      = var.project_name
  environment       = var.environment
  raw_bucket_arn    = module.s3_data_lake.raw_bucket_arn
  bronze_bucket_arn = module.s3_data_lake.bronze_bucket_arn
  silver_bucket_arn = module.s3_data_lake.silver_bucket_arn
  gold_bucket_arn   = module.s3_data_lake.gold_bucket_arn
}

module "step_functions" {
  source = "../../modules/step-functions"

  project_name = var.project_name
  environment  = var.environment
  role_arn     = module.iam.stepfunctions_role_arn
}

module "lambda_validator" {
  source = "../../modules/lambda-validator"

  project_name      = var.project_name
  environment       = var.environment
  raw_bucket_id     = module.s3_data_lake.raw_bucket_id
  raw_bucket_arn    = module.s3_data_lake.raw_bucket_arn
  lambda_role_arn   = module.iam.lambda_role_arn
  state_machine_arn = module.step_functions.state_machine_arn
}

module "glue" {
  source = "../../modules/glue"

  project_name       = var.project_name
  environment        = var.environment
  glue_role_arn      = module.iam.glue_role_arn
  raw_bucket_name    = module.s3_data_lake.raw_bucket_name
  bronze_bucket_name = module.s3_data_lake.bronze_bucket_name
  silver_bucket_name = module.s3_data_lake.silver_bucket_name
  gold_bucket_name   = module.s3_data_lake.gold_bucket_name
}