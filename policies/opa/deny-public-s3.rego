package terraform.security

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket_public_access_block"
  after := resource.change.after
  after.block_public_policy != true
  msg := sprintf("S3 bucket public policy block must be enabled: %s", [resource.address])
}