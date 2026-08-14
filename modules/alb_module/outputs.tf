output "alb_target_group_arn" {
  value = aws_lb_target_group.tf_tg.arn
}

output "alb_target_group_arn_suffix" {
  value = aws_lb_target_group.tf_tg.arn_suffix
}

output "alb_arn_suffix" {
  value = aws_lb.tf_alb.arn_suffix
}

output "alb_dns_name" {
  value = aws_lb.tf_alb.dns_name
}
