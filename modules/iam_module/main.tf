data "aws_iam_user" "frontend-developer" {
  user_name = "frontend-developer"
}

resource "aws_iam_user_policy" "frontend_deploy" {
  name = "frontend-developer"
  user = data.aws_iam_user.frontend-developer.user_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = var.frontend_bucket_arn
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"]
        Resource = "${var.frontend_bucket_arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["cloudfront:CreateInvalidation"]
        Resource = var.cloudfront_distribution_arn
      }
    ]
  })
}




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

resource "aws_iam_role" "tf_db_backup" {
  name = "${var.pjt_name}-db-backup-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "backup.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "tf_backup" {
  role       = aws_iam_role.tf_db_backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "tf_restore" {
  role       = aws_iam_role.tf_db_backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_iam_role_policy" "tf_ecs_secrets" {
  name = "${var.pjt_name}-ecs-secrets-policy"
  role = aws_iam_role.tf_ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [var.db_master_secret_arn, var.jwt_secret_arn]
      }
    ]
  })
}
