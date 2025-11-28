#############################################
# S3 BUCKET FOR APP BUILDS
#############################################

resource "aws_s3_bucket" "app_builds" {
  bucket = "techeazy-devops-app-builds"

  tags = {
    Name = "techeazy-devops-app-builds"
    Env  = var.stage
  }
}

#############################################
# UPLOAD APP.JAR (NEW RESOURCE)
#############################################

resource "aws_s3_object" "app_jar" {
  count         = var.local_app_artifact == "" ? 0 : 1

  bucket        = aws_s3_bucket.app_builds.bucket
  key           = var.s3_object_key
  source        = var.local_app_artifact
  etag          = filemd5(var.local_app_artifact)
  content_type  = "application/java-archive"
}
