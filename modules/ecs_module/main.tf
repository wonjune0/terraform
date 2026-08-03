resource "aws_ecs_cluster" "tf_ecs_cluster" {
  name = "${var.pjt_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "tf_ecs_task_definition" {
  family                   = "${var.pjt_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "4096"
  execution_role_arn       = var.ecs_task_execution_arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${var.ecr_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostport      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "tf_service" {
  name            = "${var.pjt_name}-service"
  cluster         = aws_ecs_cluster.tf_ecs_cluster.id
  task_definition = aws_ecs_task_definition.tf_ecs_task_definition.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  # Auto Scaling 동작 시 수량 덮어쓰기 방지
  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "app"
    container_port   = 80
  }
}
