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
        { name = "DB_USERNAME", value = var.db_admin_user }
      ]

      secrets = [
        { name = "DB_PASSWORD", valueFrom = "${var.db_master_secret_arn}:password::" },
        { name = "JWT_SECRET", valueFrom = var.jwt_secret_arn }
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

  lifecycle {
    ignore_changes = [container_definitions]
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.pjt_name}"
  retention_in_days = 7
}


resource "aws_ecs_service" "tf_service" {
  name            = "${var.pjt_name}_service"
  cluster         = aws_ecs_cluster.tf_ecs_cluster.id
  task_definition = aws_ecs_task_definition.tf_ecs_task_definition.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  # Auto Scaling 동작 시 수량 덮어쓰기 방지
  lifecycle {
    ignore_changes = [desired_count]
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
