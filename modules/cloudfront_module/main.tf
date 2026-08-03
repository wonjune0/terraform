resource "aws_cloudfront_distribution" "tf_cloudfront" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.pjt_name} CloudFront Distribution"
  default_root_object = "" # Single Page App이 아니면 빈값 유지 가능

  aliases = [var.sub_domain]

  # 1. 오리진(Origin) 설정: ALB 연결
  origin {
    domain_name = var.alb_dns_name # 👈 ALB의 DNS 주소
    origin_id   = "ALB_${var.pjt_name}"

    # Custom Header 주입 (방법 2: ALB에서 이 헤더 값을 검증)
    custom_header {
      name  = "X-Custom-Header"
      value = var.cloudfront_secret_header_value
    }

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # ALB 리스너가 HTTP(80)일 경우 http-only 지정
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # 2. 캐시 및 동작(Behavior) 설정
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ALB_${var.pjt_name}"

    # AWS Managed Caching Policy (CachingDisabled 또는 CachingOptimized)
    # 동적 웹 앱/API 테스트용으로는 CachingDisabled 추천
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled Policy ID

    viewer_protocol_policy = "redirect-to-https" # HTTP 접속 시 HTTPS로 자동 리다이렉트
    compress               = true
  }

  # 3. 위치 제한(Geo Restriction) - 제한 없음
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = "${var.pjt_name}_cloudfront"
  }
}
