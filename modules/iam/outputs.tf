output "lambda_role_arn" {
  value = aws_iam_role.lambda.arn
}

output "stepfunctions_role_arn" {
  value = aws_iam_role.stepfunctions.arn
}

output "glue_role_arn" {
  value = aws_iam_role.glue.arn
}