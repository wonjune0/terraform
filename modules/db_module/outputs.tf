output "db_instance_ids" {
  value = aws_rds_cluster_instance.tf_aurora_instances[*].id
}

output "db_cluster_arn" {
  value = aws_rds_cluster.tf_aurora_cluster.arn
}
