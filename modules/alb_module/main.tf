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
  subnets            = var.prisubnet_ids

  tags = {
    Name = "${var.pjt_name}_alb"
  }
}

resource "aws_alb_listener" "tf_alb_listener" {
  load_balancer_arn = aws_lb.tf_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf_tg.arn
  }
}
