provider "aws" {
  region = "us-east-1"
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "beanstalk_bucket" {
  bucket = "mi-app-node-beanstalk-${random_id.bucket_id.hex}"
}

resource "aws_s3_object" "app_zip" {
  bucket = aws_s3_bucket.beanstalk_bucket.id
  key    = "app-version.zip"
  source = "./../app-version.zip"
  acl    = "private"
}

resource "aws_elastic_beanstalk_application" "app" {
  name        = "mi-app-node"
  description = "App desplegada con Terraform"
}

resource "aws_elastic_beanstalk_application_version" "app_version" {
  name        = "v1-${timestamp()}"
  application = aws_elastic_beanstalk_application.app.name
  bucket      = aws_s3_bucket.beanstalk_bucket.id
  key         = aws_s3_object.app_zip.key
}

resource "aws_elastic_beanstalk_environment" "env" {
  name                = "mi-app-node-env"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Amazon Linux 2 v5.10.0 running Node.js 18"
  version_label       = aws_elastic_beanstalk_application_version.app_version.name

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.micro"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "NODE_ENV"
    value     = "production"
  }
}

