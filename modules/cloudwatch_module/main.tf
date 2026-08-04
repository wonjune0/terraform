resource "aws_cloudwatch_metric_alarm" "tf_alb_5XX" {
  alarm_name          = "${var.pjt_name}-alb-5XX"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60 # 측정 주기 (초)
  statistic           = "Sum"
  threshold           = 5

  alarm_description = "ALB Target group returning 5XX errors"
  alarm_actions     = [var.sns_topic_arn]

  dimensions = {
    TargetGroup  = var.alb_targetgroup_arn
    LoadBalancer = var.alb_arn
  }
}

resource "aws_cloudwatch_metric_alarm" "tf_ecs_cpu_high" {
  alarm_name          = "${var.pjt_name}-ecs-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2 # 2회 연속
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  alarm_description = "ECS Service CPU utilization is higher than 80%"
  alarm_actions     = [var.sns_topic_arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_high_connections" {
  count               = length(var.db_instance_ids)
  alarm_name          = "${var.pjt_name}-rds-${var.db_instance_ids[count.index]}-high-connections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 80

  alarm_description = "RDS Database conntections are high"
  alarm_actions     = [var.sns_topic_arn]

  dimensions = {
    DBInstanceIdentifier = var.db_instance_ids[count.index]
  }
}
