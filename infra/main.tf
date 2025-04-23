provider "aws" {
  region = "us-east-1"
}

resource "random_id" "bucket_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "beanstalk_bucket" {
  bucket = "mi-app-node-beanstalk-${random_id.bucket_id.hex}"
}

resource "aws_s3_object" "app_zip" {
  bucket = aws_s3_bucket.beanstalk_bucket.bucket
  key    = "app-version.zip"
  source = "./app-version.zip"  # Asegúrate de que esta ruta sea correcta
}

resource "aws_elastic_beanstalk_application" "app" {
  name        = "mi-app-node"
  description = "Mi aplicación Node.js"
}

resource "aws_elastic_beanstalk_environment" "env" {
  name                = "mi-app-node-env"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack      = "64bit Amazon Linux 2 v3.3.6 running Node.js 18"
  version_label       = "v1"
  s3_bucket           = aws_s3_bucket.beanstalk_bucket.bucket
  s3_key              = aws_s3_object.app_zip.key

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "4"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
  }
}
