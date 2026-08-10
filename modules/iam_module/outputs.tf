output "ecs_task_execution_role_arn" {
  value = aws_iam_role.tf_ecs_task_execution_role.arn
}

output "db_backup_role_arn" {
  value = aws_iam_role.tf_db_backup.arn
}
