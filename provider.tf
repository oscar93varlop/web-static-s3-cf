terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.20.1"

    }
  }
}

provider "aws" {
    # shared_config_files      = ["/home/ovl93/.aws/config"]
    # shared_credentials_files = ["/home/ovl93/.aws/creddentials"]
    # profile   = "gtest"
  # Configuration options
  default_tags {
    tags = {
      env = "web-static-s3-cf",
      "onwer" = "Oscar A Vargas"

    }
  }
}

terraform {
  backend "s3" {
    bucket         = "website-s3-cf"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "website-s3-cf"
  }
}
resource "aws_s3_bucket" "s3-backend" {
    bucket = "website-s3-cf"
    versioning {
        enabled = true
    }
    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }
    object_lock_configuration {
        object_lock_enabled = "Enabled"
    }
    tags = {
        Name = "S3 Remote Terraform State Store"
    }
}
resource "aws_dynamodb_table" "dynamo-backend" {
    name           = "website-s3-cf"
    read_capacity  = 5
    write_capacity = 5
    hash_key       = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
    tags = {
        "Name" = "DynamoDB Terraform State Lock Table"
    }
}