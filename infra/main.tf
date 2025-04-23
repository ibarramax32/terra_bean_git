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
