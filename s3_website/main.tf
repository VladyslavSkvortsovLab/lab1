terraform {
	required_providers {
		aws = {
		source = "hashicorp/aws"
		version = "~> 4.0"
		}
	}
}

# Configure AWS provider and creds
provider "aws" {
	region = "us-east-1"
	shared_config_files = ["C:/Users/vlady/.aws/config.txt"]
shared_credentials_files = ["C:/Users/vlady/.aws/credentials.txt"]
profile = "default"
}

# Creating bucket
resource "aws_s3_bucket" "website" {
	bucket = "terraform-vlad-bucket"
	tags = {
		Name = "Website"
		Environment = "Dev"
	}
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
	}

resource "aws_s3_bucket_website_configuration" "website_config" {
	bucket = aws_s3_bucket.website.id
	index_document {
		suffix = "index.html"
	}
	error_document {
		key = "error.html"
	}
}

resource "aws_s3_bucket_policy" "allow_access" {
	bucket = aws_s3_bucket.website.id
	policy = data.aws_iam_policy_document.allow_access.json
}

data "aws_iam_policy_document" "allow_access" {
	statement {
		principals {
			type = "AWS"
			identifiers = ["*"]
		}
		actions = [ "s3:GetObject" ]
		resources = [ aws_s3_bucket.website.arn,
		"${aws_s3_bucket.website.arn}/*", ]
	}
}

resource "aws_s3_object" "indexfile" {
	bucket = aws_s3_bucket.website.id
	key = "index.html"
	source = "./src/index.html"
	content_type = "text/html"
}

output "website_endpoint" {
	value = aws_s3_bucket_website_configuration.website_config.website_endpoint
}
