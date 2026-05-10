resource "aws_cloudwatch_log_group" "sfn" {
  name              = "/aws/vendedlogs/states/${var.project_name}-${var.environment}-pipeline"
  retention_in_days = 14
}


resource "aws_sfn_state_machine" "this" {
  name     = "${var.project_name}-${var.environment}-pipeline"
  role_arn = var.role_arn

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.sfn.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  tracing_configuration {
    enabled = true
  }

  definition = jsonencode({
    Comment = "Batch data platform orchestration"
    StartAt = "RunGlueJob"
    States = {
      RunGlueJob = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = "${var.project_name}-${var.environment}-sales-etl"
          Arguments = {
            "--BUCKET_NAME.$" = "$.bucket"
            "--SOURCE_KEY.$"  = "$.key"
          }
        }
        End = true
      }
    }
  })
}