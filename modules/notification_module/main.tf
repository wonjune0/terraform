resource "aws_sns_topic" "tf_alarm_topic" {
  name = "${var.pjt_name}-sns-alarm-topic"
}

resource "aws_sns_topic_subscription" "tf_email_sub" {
  topic_arn = aws_sns_topic.tf_alarm_topic.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}
