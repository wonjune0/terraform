data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_acm_certificate" "tf_acm_certificate" {
  domain_name       = var.sub_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "tf_record_validation" {
  for_each = {
    for dvo in aws_acm_certificate.tf_acm_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}

resource "aws_acm_certificate_validation" "tf_acm_cert_validation" {
  certificate_arn         = aws_acm_certificate.tf_acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.tf_record_validation : record.fqdn]
}

resource "aws_route53_record" "cloudfront_alias" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.sub_domain
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}
