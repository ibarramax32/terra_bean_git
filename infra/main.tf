provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "beanstalk_bucket" {
  bucket = "${var.project_name}-beanstalk-${random_id.bucket_id.hex}"
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket_object" "app_zip" {
  bucket = aws_s3_bucket.beanstalk_bucket.id
  key    = "app-version.zip"
  source = "${path.module}/../app-version.zip"
  etag   = filemd5("${path.module}/../app-version.zip")
}

resource "aws_elastic_beanstalk_application" "app" {
  name        = var.project_name
  description = "App desplegada con Terraform"
}

resource "aws_elastic_beanstalk_environment" "env" {
  name                = "${var.project_name}-env"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Amazon Linux 2 v5.8.4 running Node.js 18"

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

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance"
  }

  version_label = aws_elastic_beanstalk_application_version.app_version.name
}

resource "aws_elastic_beanstalk_application_version" "app_version" {
  name        = "v1-${timestamp()}"
  application = aws_elastic_beanstalk_application.app.name
  bucket      = aws_s3_bucket.beanstalk_bucket.id
  key         = aws_s3_bucket_object.app_zip.id
}
