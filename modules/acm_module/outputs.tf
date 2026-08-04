output "acm_certificate_arn" {
  value = aws_acm_certificate.tf_acm_certificate.arn
}

output "hosted_zone_id" {
  value = data.aws_route53_zone.main.zone_id
}
