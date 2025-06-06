resource "aws_s3_bucket" "auth_service_images" {
  bucket = "auth-service-public-images-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "auth_service_images_block" {
  bucket = aws_s3_bucket.auth_service_images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
