resource "aws_s3_bucket" "beanstalk_bucket" {
  bucket = "mi-app-node-beanstalk-bucket-unique" # Cambia el nombre del bucket para hacerlo único
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
  solution_stack      = "64bit Amazon Linux 2 v5.6.1 running Node.js 18" # Actualiza con la solución correcta
  platform            = "Node.js 18 on 64bit Amazon Linux 2"
  tier {
    name = "WebServer"
    type = "Standard"
  }
}

resource "aws_s3_object" "app_zip" {
  bucket = aws_s3_bucket.beanstalk_bucket.bucket
  key    = "app-version.zip"
  source = "app/app-version.zip"  # Asegúrate de que el archivo existe en la ubicación indicada
  acl    = "private"
}


