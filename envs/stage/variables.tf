variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-2"
}

variable "project_name" {
  type        = string
  description = "Project name"
  default     = "sales-data-platform"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "stage"
}

variable "common_tags" {
  type = map(string)

  default = {
    Project     = "sales-data-platform"
    Environment = "stage"
    ManagedBy   = "Terraform"
    Owner       = "platform-engineering"
  }
}