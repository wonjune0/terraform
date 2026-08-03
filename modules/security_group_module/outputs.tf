output "alb_sg_id" {
  value = aws_security_group.tf_alb_sg.id
}

output "vpc_ecr_sg_id" {
  value = aws_security_group.tf_vpc_ecr_sg.id
}

output "ecs_sg_id" {
  value = aws_security_group.tf_ecs_sg.id
}
