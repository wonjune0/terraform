resource "aws_iam_role" "tf_ecs_task_execution_role" {
  name = "${var.pjt_name}-ecs-task-execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.pjt_name}_ecs_task_execution_role"
  }
}

resource "aws_iam_role_policy_attachment" "tf_ecs_task_execution_role_policy" {
  role       = aws_iam_role.tf_ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "tf_rds_s3_export_role" {
  name = "${var.pjt_name}-rds-s3-export-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "rds.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "tf_rds_s3_export_policy" {
  name = "${var.pjt_name}-rds-s3-export-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:AbortMultipartUpload",
        "s3:ListBucket"
      ]
      Resource = [
        var.db_backup_bucket_arn,
        "${var.db_backup_bucket_arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "tf_rds_s3_export_attach" {
  role       = aws_iam_role.tf_rds_s3_export_role.name
  policy_arn = aws_iam_policy.tf_rds_s3_export_policy.arn
}
