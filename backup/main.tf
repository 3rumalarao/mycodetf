
resource "aws_backup_vault" "this" {
  name = "${var.backup_policy.resource_tag_filter}-vault"

  tags = merge(var.common_tags, { # Apply common tags
    Name = "${var.backup_policy.resource_tag_filter}-backup-vault"
  })
}

resource "aws_backup_plan" "this" {
  name = "${var.backup_policy.resource_tag_filter}-plan"

  rule {
    rule_name         = "daily-snapshot" # Or make this configurable if needed
    target_vault_name = aws_backup_vault.this.name
    # Use schedule from the variable
    schedule          = var.backup_policy.schedule # CORRECTED: Use variable

    lifecycle {
      delete_after = var.backup_policy.retention_days
      # Optional: Add cold storage transition if needed
      # cold_storage_after = var.backup_policy.retention_days + 90
    }
    # Optional: Add copy actions if needed
    # copy_action { ... }
  }

  # REMOVED: advanced_backup_setting block.

  tags = merge(var.common_tags, { # Apply common tags
    Name = "${var.backup_policy.resource_tag_filter}-backup-plan"
  })
}

resource "aws_backup_selection" "this" {
  name         = "${var.backup_policy.resource_tag_filter}-selection"
  iam_role_arn = data.aws_iam_role.backup.arn
  plan_id      = aws_backup_plan.this.id

  # --- Corrected Tag-Based Selection ---
  selection_tag {
    type  = "STRINGEQUALS"
    # Use tag key from the variable
    key   = var.backup_policy.resource_tag_key # CORRECTED: Use variable
    # Use tag value from the variable
    value = var.backup_policy.resource_tag_filter
  }

  # No tags needed on the selection resource itself usually
}

data "aws_iam_role" "backup" {
  # Looks up the default AWS Backup role. Ensure it exists and has permissions.
  name = "AWSBackupDefaultServiceRole"
}
