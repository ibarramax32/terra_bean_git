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
  source = "app/app-version.zip"  # Ruta al archivo ZIP dentro de la carpeta 'app'
}

resource "aws_elastic_beanstalk_environment" "env" {
  name                = "mi-app-node-env"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack      = "64bit Amazon Linux 2 v3.3.6 running Node.js 18"  # Definir la solución para Node.js
  version_label       = "v1"
  cname_prefix        = "mi-app-node"  # Definir el dominio CNAME si es necesario

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

  application_version = aws_s3_object.app_zip.key  # Aquí pasamos la referencia al archivo zip como versión de la app
}

