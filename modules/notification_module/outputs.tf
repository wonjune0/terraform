output "sns_topic_arn" {
  value = aws_sns_topic.tf_alarm_topic.arn
}
