resource "aws_s3_bucket" "beanstalk_bucket" {
  bucket = "mi-app-node-beanstalk-bucket-unique"
}

resource "aws_s3_bucket_acl" "beanstalk_bucket_acl" {
  bucket = aws_s3_bucket.beanstalk_bucket.bucket
  acl    = "private"
}

resource "aws_elastic_beanstalk_application" "app" {
  name = "mi-app-node"
}

resource "aws_elastic_beanstalk_environment" "env" {
  name                = "mi-app-node-env"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Amazon Linux 2 v5.6.1 running Node.js 18"

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "3"
  }
}
