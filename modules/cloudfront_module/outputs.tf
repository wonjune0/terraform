output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.tf_cloudfront.domain_name
}

output "cloudfront_hosted_zone_id" {
  value = aws_cloudfront_distribution.tf_cloudfront.hosted_zone_id
}

output "cloudfront_distribution_arn" {
  value = aws_cloudfront_distribution.tf_cloudfront.arn
}
