resource "aws_backup_vault" "tf_seoul" {
  name = "${var.pjt_name}-seoul-backup-vault"
}

resource "aws_backup_vault" "tf_osaka" {
  provider = aws.ap_northeast_3
  name     = "${var.pjt_name}-osake-backup-vault"
}

resource "aws_backup_plan" "tf_db_backup_plan" {
  name = "${var.pjt_name}-db-backup-plan"

  rule {
    rule_name         = "daily_backup"
    target_vault_name = aws_backup_vault.tf_seoul.name
    schedule          = "cron(0 15 * * ? *)"
    start_window      = 60
    completion_window = 180

    lifecycle {
      delete_after = 30
    }

    copy_action {
      destination_vault_arn = aws_backup_vault.tf_osaka.arn

      lifecycle {
        delete_after = 30
      }
    }
  }
}


resource "aws_backup_selection" "tf_backup_db_selection" {
  name         = "${var.pjt_name}-db-backup-selection"
  plan_id      = aws_backup_plan.tf_db_backup_plan.id
  iam_role_arn = var.db_backup_role_arn

  resources = [var.db_cluster_arn]
}
