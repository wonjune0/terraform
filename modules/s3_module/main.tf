data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "tf_frontend_bucket" {
  bucket = "${var.pjt_name}-frontend-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_public_access_block" "tf_frontend_bucket_access" {
  bucket                  = aws_s3_bucket.tf_frontend_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "tf_frontend_bucket_policy" {
  bucket = aws_s3_bucket.tf_frontend_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "cloudfront.amazonaws.com" }
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.tf_frontend_bucket.arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = var.cloudfront_distribution_arn
        }
      }
    }]
  })
}
