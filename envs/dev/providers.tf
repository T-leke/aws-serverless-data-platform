terraform {
  required_version = ">= 1.5.0"

  cloud {
    organization = "learn-terraform-ogidan"

    workspaces {
      name = "aws-data-platform-dev"
    }
  }



  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}