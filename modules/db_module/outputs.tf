output "db_instance_ids" {
  value = aws_rds_cluster_instance.tf_aurora_instances[*].id
}

output "db_cluster_arn" {
  value = aws_rds_cluster.tf_aurora_cluster.arn
}

output "db_cluster_endpoint" {
  value = aws_rds_cluster.tf_aurora_cluster.endpoint
}

output "db_cluster_reader_endpoint" {
  value = aws_rds_cluster.tf_aurora_cluster.reader_endpoint
}

output "db_master_secret_arn" {
  value = aws_rds_cluster.tf_aurora_cluster.master_user_secret[0].secret_arn
}
