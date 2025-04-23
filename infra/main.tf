provider "aws" {
  region = "us-east-1"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "beanstalk_bucket" {
  bucket = "mi-app-node-beanstalk-bucket-${random_id.bucket_suffix.hex}"
  acl    = "private"
}

resource "aws_s3_bucket_policy" "beanstalk_bucket_policy" {
  bucket = aws_s3_bucket.beanstalk_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "s3:GetObject"
        Effect    = "Allow"
        Resource  = "${aws_s3_bucket.beanstalk_bucket.arn}/*"
        Principal = "*"
      }
    ]
  })
}

resource "aws_elastic_beanstalk_application" "app" {
  name = "mi-app-node"
}

resource "aws_elastic_beanstalk_environment" "env" {
  name                = "mi-app-node-env"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Amazon Linux 2 v5.6.1 running Node.js 18"
  tier                = "WebServer"
  setting {
    namespace   = "aws:elasticbeanstalk:application:environment"
    option_name = "ENV_VAR"
    value       = "value"
  }
}

