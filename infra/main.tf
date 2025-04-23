provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "beanstalk_bucket" {
  bucket = "mi-app-node-beanstalk-bucket-unique"
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
  name        = "mi-app-node-env"
  application = aws_elastic_beanstalk_application.app.name
  platform    = "64bit Amazon Linux 2023 v5.6.1 running Tomcat 9 Corretto 11" # Actualiza con la solución correcta
  tier        = "WebServer"

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ENV_VAR"
    value     = "value"
  }
}

