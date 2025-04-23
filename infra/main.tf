resource "aws_elastic_beanstalk_application" "app" {
  name        = "mi-app-node"
  description = "Node.js Application"
}

resource "aws_s3_bucket" "beanstalk_bucket" {
  bucket = "mi-app-node-beanstalk-bucket"
}

resource "aws_s3_object" "app_zip" {
  bucket = aws_s3_bucket.beanstalk_bucket.bucket
  key    = "app-version.zip"
  source = "app/app-version.zip"
}

resource "aws_elastic_beanstalk_environment" "env" {
  name                = "mi-app-node-env"
  application         = aws_elastic_beanstalk_application.app.name
  version_label       = "v1"
  cname_prefix        = "mi-app-node"

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
