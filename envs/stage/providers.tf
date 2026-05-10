terraform {
  required_version = ">= 1.5.0"

  cloud {
    organization = "learn-terraform-ogidan"

    workspaces {
      name = "aws-data-platform-stage"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}