provider "aws" {
  region = "us-west-2" # Asegúrate de ajustar la región a la que estés utilizando
}

# Crear un bucket S3 para almacenar la aplicación
resource "aws_s3_bucket" "beanstalk_bucket" {
  bucket = "mi-app-node-beanstalk-${random_id.bucket_id.hex}"
}

# Crear un identificador aleatorio para evitar conflictos de nombres
resource "random_id" "bucket_id" {
  byte_length = 8
}

# Subir el archivo ZIP de la aplicación a S3
resource "aws_s3_object" "app_zip" {
  bucket = aws_s3_bucket.beanstalk_bucket.id
  key    = "app-version.zip"
  source = "path/to/your/app-version.zip" # Asegúrate de especificar la ruta correcta del archivo ZIP
  acl    = "private"
}

# Crear la aplicación de Elastic Beanstalk
resource "aws_elastic_beanstalk_application" "app" {
  name        = "mi-app-node"
  description = "Aplicación Node.js para Beanstalk"
}

# Crear la versión de la aplicación en Elastic Beanstalk
resource "aws_elastic_beanstalk_application_version" "app_version" {
  name        = "app-version-${random_id.bucket_id.hex}"
  application = aws_elastic_beanstalk_application.app.name
  bucket      = aws_s3_bucket.beanstalk_bucket.id
  key         = aws_s3_object.app_zip.key
}

# Crear el entorno de Elastic Beanstalk
resource "aws_elastic_beanstalk_environment" "env" {
  name                = "mi-app-node-env"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Amazon Linux 2 v5.10.0 running Node.js 18"
  version_label       = aws_elastic_beanstalk_application_version.app_version.name

  depends_on = [
    aws_elastic_beanstalk_application.app,
    aws_elastic_beanstalk_application_version.app_version
  ]

  lifecycle {
    create_before_destroy = true
  }

  timeout {
    create = "60m" # Ajusta este valor según lo necesites
  }
}
