resource "aws_backup_vault" "this" {
  name = "${var.backup_policy.resource_tag_filter}-vault"
}

resource "aws_backup_plan" "this" {
  name = "${var.backup_policy.resource_tag_filter}-plan"

  rule {
    rule_name         = "daily-snapshot"
    schedule          = "cron(0 5 * * ? *)"
    lifecycle {
      delete_after = var.backup_policy.retention_days
    }
  }
}

resource "aws_backup_selection" "this" {
  name         = "${var.backup_policy.resource_tag_filter}-selection"
  iam_role_arn = data.aws_iam_role.backup.arn
  plan_id      = aws_backup_plan.this.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Name"
    value = "${var.backup_policy.resource_tag_filter}*"
  }
}

data "aws_iam_role" "backup" {
  name = "AWSBackupDefaultServiceRole"
}
