provider "aws" {
  region = "us-east-1"  # Cambia esto si usas otra región
}

resource "aws_s3_bucket" "beanstalk_bucket" {
  bucket = "mi-app-node-beanstalk-bucket"
}

resource "aws_s3_object" "app_zip" {
  bucket = aws_s3_bucket.beanstalk_bucket.bucket
  key    = "app-version.zip"
  source = "app-version.zip"  # Asegúrate de que el archivo zip esté en el directorio correcto
}

resource "aws_elastic_beanstalk_application" "app" {
  name        = "mi-app-node"
  description = "Aplicación Node.js en Elastic Beanstalk"
}

resource "aws_elastic_beanstalk_environment" "env" {
  name                = "mi-app-node-env"
  application         = aws_elastic_beanstalk_application.app.name
  version_label       = "v1"
  cname_prefix        = "mi-app-node"
  
  solution_stack_name = "64bit Amazon Linux 2 v3.3.6 running Node.js 18"  # Define la solución aquí

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "4"
  }
}

