output "ecs_cluster_name" {
  value = aws_ecs_cluster.tf_ecs_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.tf_service.name
}
