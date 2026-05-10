resource "aws_athena_workgroup" "this" {
  name = "${var.project_name}-${var.environment}-workgroup"

  configuration {
    enforce_workgroup_configuration = true

    result_configuration {
      output_location = "s3://${var.athena_results_bucket_name}/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}