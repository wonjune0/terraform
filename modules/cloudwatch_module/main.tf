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
    TargetGroup  = var.alb_target_group_arn_suffix
    LoadBalancer = var.alb_arn_suffix
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

# 결제가 붙으면서 응답시간이 성능 지표의 중심이 된다. 5XX는 이미 터진 뒤의 신호이고,
# p95 지연은 그 전에 올라간다. 평균 대신 p95를 보는 이유는 결제만 느려지고 조회는
# 멀쩡한 상황에서 평균이 거의 움직이지 않기 때문이다.
resource "aws_cloudwatch_metric_alarm" "tf_alb_latency_p95" {
  alarm_name          = "${var.pjt_name}-alb-latency-p95"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  extended_statistic  = "p95"
  threshold           = 3
  treat_missing_data  = "notBreaching"

  alarm_description = "ALB p95 latency above 3s -- payment path or database contention"
  alarm_actions     = [var.sns_topic_arn]

  dimensions = {
    TargetGroup  = var.alb_target_group_arn_suffix
    LoadBalancer = var.alb_arn_suffix
  }
}
