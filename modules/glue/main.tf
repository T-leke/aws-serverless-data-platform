resource "aws_glue_catalog_database" "this" {
  name = "${var.project_name}_${var.environment}_db"
}

resource "aws_s3_object" "glue_script" {
  bucket = var.raw_bucket_name
  key    = "scripts/sales_etl.py"
  source = "${path.root}/../../glue/jobs/sales_etl.py"
  etag   = filemd5("${path.root}/../../glue/jobs/sales_etl.py")
}

resource "aws_glue_security_configuration" "this" {
  name = "${var.project_name}-${var.environment}-glue-security-config"

  encryption_configuration {
    cloudwatch_encryption {
      cloudwatch_encryption_mode = "DISABLED"
    }

    job_bookmarks_encryption {
      job_bookmarks_encryption_mode = "DISABLED"
    }

    s3_encryption {
      s3_encryption_mode = "SSE-S3"
    }
  }
}


resource "aws_glue_job" "sales_etl" {
  name     = "${var.project_name}-${var.environment}-sales-etl"
  role_arn = var.glue_role_arn

  security_configuration = aws_glue_security_configuration.this.name

  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2
  timeout           = 10

  command {
    name            = "glueetl"
    script_location = "s3://${var.raw_bucket_name}/${aws_s3_object.glue_script.key}"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                   = "true"
    "--BRONZE_BUCKET"                    = var.bronze_bucket_name
    "--SILVER_BUCKET"                    = var.silver_bucket_name
    "--GOLD_BUCKET"                      = var.gold_bucket_name
  }
}

resource "aws_glue_crawler" "gold" {
  name          = "${var.project_name}-${var.environment}-gold-crawler"
  role          = var.glue_role_arn
  database_name = aws_glue_catalog_database.this.name

  security_configuration = aws_glue_security_configuration.this.name

  s3_target {
    path = "s3://${var.gold_bucket_name}/daily_sales_summary/"
  }
} 