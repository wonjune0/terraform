output "frontend_bucket_name" {
  value = aws_s3_bucket.tf_frontend_bucket.bucket_domain_name
}
