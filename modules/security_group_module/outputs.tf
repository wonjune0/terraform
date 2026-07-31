output "alb_sg_id" {
  value = aws_security_group.tf-alb-sg.id
}

output "vpc_ecs_sg_id" {
  value = aws_security_group.tf_vpc_ecs_sg.id
}
