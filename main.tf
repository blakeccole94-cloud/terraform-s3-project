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
resource "aws_s3_bucket" "project6_bucket" {
  bucket = "cloud-plus-blake-project6"
}
resource "aws_s3_bucket_versioning" "project6_versioning" {
  bucket = aws_s3_bucket.project6_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "project6_encryption" {
  bucket = aws_s3_bucket.project6_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "project6_lifecycle" {
  bucket = aws_s3_bucket.project6_bucket.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}
terraform {
  backend "s3" {
    bucket = "cloud-plus-blake-lab"
    key    = "project6/terraform.tfstate"
    region = "us-east-1"
  }
}