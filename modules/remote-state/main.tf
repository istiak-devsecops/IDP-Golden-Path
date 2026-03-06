# Provider
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>6.0"
    }
  }

  backend "s3" {
   bucket       = "idp-bucket-istiaks369"
   key          = "platform/core.tfstate"
   region       = "us-west-2"
   encrypt      = true
   use_lockfile = true  # THIS REPLACES DYNAMODB
  }
}

provider "aws" {
  region = "us-west-2"
}

# S3 Bucket
resource "aws_s3_bucket" "idp_bucket" {
  bucket = "${var.storage_name}"

  tags = {
    Name        = "My bucket"
    Environment = "test"
  }
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "idp_versioning_s3" {
  bucket = aws_s3_bucket.idp_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "s3_access" {
  bucket = aws_s3_bucket.idp_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 server side encryption
resource "aws_kms_key" "idp_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encrypt" {
  bucket = aws_s3_bucket.idp_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.idp_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}