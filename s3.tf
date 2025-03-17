terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "GR-S3-Bucket-CodePipeline" {
  bucket              = "gr-s3-bucket-codepipeline"
  object_lock_enabled = true

  tags = {
    Name        = "GR bucket for CodePipeline deployments"
    Environment = "Sandbox"
  }
}