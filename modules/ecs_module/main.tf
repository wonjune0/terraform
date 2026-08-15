resource "aws_ecs_cluster" "tf_ecs_cluster" {
  name = "${var.pjt_name}_cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "tf_ecs_task_definition" {
  family                   = "${var.pjt_name}_task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_task_execution_arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${var.ecr_url}:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]

      environment = [
        { name = "SPRING_PROFILES_ACTIVE", value = "prod" },
        { name = "DB_HOST", value = var.db_cluster_endpoint },
        { name = "DB_NAME", value = var.db_name },
        { name = "DB_USERNAME", value = var.db_admin_user },
        # 재고 차감 전략. 부하 테스트에서 세 방식을 비교할 때 이미지를 다시 빌드하지 않고
        # 이 값만 바꿔서 배포하면 된다.
        { name = "STOCK_STRATEGY", value = var.stock_strategy },
        # 결제 실패 주입. 시연 영상 촬영 때만 켜고 평소에는 꺼 둔다.
        { name = "PAYMENT_ALLOW_FORCED_FAILURE", value = tostring(var.payment_allow_forced_failure) }
      ]

      secrets = [
        { name = "DB_PASSWORD", valueFrom = "${var.db_master_secret_arn}:password::" },
        { name = "JWT_SECRET", valueFrom = var.jwt_secret_arn },
        { name = "PAYMENT_SECRET_KEY", valueFrom = var.payment_secret_arn }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.pjt_name}"
          "awslogs-region"        = "ap-northeast-2"
          "awslogs-stream-prefix" = "app"
        }
      }
    }
  ])

  # container_definitions를 무시하지 않는다.
  # 무시하면 여기서 환경변수나 시크릿을 아무리 고쳐도 새 리비전이 등록되지 않아
  # 컨테이너까지 전달되지 않는다. 이미지 태그를 CD가 덮어쓰는 문제는 아래
  # aws_ecs_service의 ignore_changes = [task_definition]이 이미 막고 있다.
  # CD는 describe-task-definition으로 최신 리비전을 받아 이미지만 바꿔 등록하므로,
  # 여기서 등록한 환경변수/시크릿은 다음 배포에 그대로 실려 간다.
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.pjt_name}"
  retention_in_days = 7
}


resource "aws_ecs_service" "tf_service" {
  name                              = "${var.pjt_name}_service"
  cluster                           = aws_ecs_cluster.tf_ecs_cluster.id
  task_definition                   = aws_ecs_task_definition.tf_ecs_task_definition.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 120

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  # Auto Scaling 동작 시 수량 덮어쓰기 방지
  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }

  network_configuration {
    subnets          = var.private_subnet_ids_list
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "app"
    container_port   = 80
  }
}

resource "aws_appautoscaling_target" "tf_ecs_target" {
  min_capacity       = 2
  max_capacity       = 10
  resource_id        = "service/${aws_ecs_cluster.tf_ecs_cluster.name}/${aws_ecs_service.tf_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "tf_ecs_policy" {
  name               = "${var.pjt_name}_cpu_autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.tf_ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.tf_ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.tf_ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}
