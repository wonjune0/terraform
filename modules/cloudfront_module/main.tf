# ==========================================
# 1. CloudFront Distribution 생성
# ==========================================
resource "aws_cloudfront_distribution" "alb_cdn" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.pjt_name} CloudFront for ALB"
  price_class     = "PriceClass_200" # 한국, 아시아, 북미, 유럽 지점 포함 (비용 절감형)

  # 도메인 커스텀 설정 시 등록 (예: app.example.com)
  # aliases = ["app.example.com"]

  # ----------------------------------------
  # Origin (백엔드 ALB 연결)
  # ----------------------------------------
  origin {
    domain_name = aws_lb.alb.dns_name # ALB의 DNS 주소
    origin_id   = "ALB-${aws_lb.alb.name}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # CloudFront ➔ ALB 통신 (ALB가 HTTP 80만 받는 경우)
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    # 보안 강화를 위한 Custom Header (CloudFront를 통한 요청만 ALB가 받도록 제한할 때 사용)
    custom_header {
      name  = "X-Custom-Header"
      value = var.cloudfront_secret_header_value
    }
  }

  # ----------------------------------------
  # Default Cache Behavior (기본 동작 및 캐싱)
  # ----------------------------------------
  default_cache_behavior {
    target_origin_id       = "ALB-${aws_lb.alb.name}"
    viewer_protocol_policy = "redirect-to-https" # HTTP 접속 시 HTTPS로 자동 리다이렉트

    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]

    # ALB 백엔드로 요청을 보낼 때 쿠키, 헤더, 쿼리스트링 전달 설정
    # AWS 관리형 정책 사용: CachingDisabled (동적 API/ECS 응답은 기본 캐싱 비활성화)
    cache_policy_id          = "41355a44-4028-453e-8d91-8a3059e432a4" # CachingDisabled
    origin_request_policy_id = "216fd400-66a5-4580-a636-bcb2c92d6458" # AllViewerExceptHostHeader

    compress = true # Gzip / Brotli 자동 압축
  }

  # ----------------------------------------
  # 국가별 접근 제한 (필요 없으면 none)
  # ----------------------------------------
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # ----------------------------------------
  # SSL/TLS 인증서 설정
  # ----------------------------------------
  viewer_certificate {
    # 1) 커스텀 도메인이 없을 때: 기본 CloudFront SSL(*.cloudfront.net) 사용
    cloudfront_default_certificate = true

    # 2) 커스텀 도메인 사용 시 (ACM 인증서는 반드시 us-east-1 버지니아 북부 리전에 위치해야 함)
    # acm_certificate_arn      = aws_acm_certificate.cert.arn
    # ssl_support_method       = "sni-only"
    # minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name        = "${var.pjt_name}_cloudfront"
    Environment = var.environment
  }
}

# ==========================================
# 2. Outputs
# ==========================================
output "cloudfront_domain_name" {
  description = "사용자가 접속할 CloudFront 도메인 주소"
  value       = aws_cloudfront_distribution.alb_cdn.domain_name
}
