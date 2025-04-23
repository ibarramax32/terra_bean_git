provider "aws" {
  region = var.aws_region
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "beanstalk_bucket" {
  bucket = "mi-app-node-beanstalk-bucket-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket_acl" "beanstalk_bucket_acl" {
  bucket = aws_s3_bucket.beanstalk_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "beanstalk_bucket_public_access" {
  bucket = aws_s3_bucket.beanstalk_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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
        Principal = {
          AWS = "arn:aws:iam::172373721600:root" # Reemplaza con el ARN correcto
        }
      }
    ]
  })
}

resource "aws_elastic_beanstalk_application" "app" {
  name = var.project_name
}

resource "aws_elastic_beanstalk_environment" "env" {
  name                = "mi-app-node-env"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Amazon Linux 2023 v5.6.1 running Tomcat 9 Corretto 11"
  tier                = "WebServer"
}

