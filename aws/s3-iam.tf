resource "aws_cloudfront_origin_access_identity" "s3_oai" {
  comment = "Origin Access Identity for S3 auth service images bucket"
}

resource "aws_s3_bucket_policy" "auth_service_images_policy" {
  bucket = aws_s3_bucket.auth_service_images.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.s3_oai.iam_arn
        },
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.auth_service_images.arn}/*"
      }
    ]
  })
}
