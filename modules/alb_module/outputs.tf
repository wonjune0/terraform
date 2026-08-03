output "alb_target_group_arn" {
  value = aws_lb_target_group.tf_tg.arn
}

output "alb_dns_name" {
  value = aws_lb.tf_alb.dns_name
}
