resource "aws_lb_target_group" "tf_tg" {
  name        = "${var.pjt_name}-ecs-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # ECS Fargate는 반드시 ip로 설정해야 함

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name = "${var.pjt_name}_ecs_tg"
  }
}


resource "aws_lb" "tf_alb" {
  name               = "${var.pjt_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg]
  subnets            = var.pubsubnet_ids_list

  # 결제 요청은 외부 게이트웨이 응답을 기다리므로 일반 조회보다 오래 걸린다.
  # 기본값(60초)에 의존하지 않고 명시해 둔다. 이 값을 넘기면 ALB가 504를 돌려주는데,
  # 그 시점엔 주문이 PENDING으로 남아 있으므로 클라이언트 재시도는 반드시
  # 같은 Idempotency-Key로 나가야 한다.
  idle_timeout = 60

  tags = {
    Name = "${var.pjt_name}_alb"
  }
}

resource "aws_lb_listener" "tf_alb_listener" {
  load_balancer_arn = aws_lb.tf_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Access Denied: Direct access to ALB is not allowed."
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener_rule" "tf_allow_cloudfront" {
  listener_arn = aws_lb_listener.tf_alb_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf_tg.arn
  }

  condition {
    http_header {
      http_header_name = "X-Custom-Header"
      values           = [var.cloudfront_secret_header_value]
    }
  }
}
