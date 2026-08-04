output "db_instance_ids" {
  value = aws_rds_cluster_instance.tf_aurora_instances[*].id
}
