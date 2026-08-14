output "frontend_bucket_name" {
  value = aws_s3_bucket.tf_frontend_bucket.bucket_regional_domain_name
}

output "frontend_bucket_arn" {
  value = aws_s3_bucket.tf_frontend_bucket.arn
}

output "frontend_bucket_id" {
  value = aws_s3_bucket.tf_frontend_bucket.id
}
