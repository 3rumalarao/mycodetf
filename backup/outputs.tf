output "backup_plan_id" {
  description = "The ID of the AWS Backup plan created." # Added description for clarity
  value       = aws_backup_plan.this.id
}

output "backup_vault_name" {
  description = "The name of the AWS Backup vault created."
  value       = aws_backup_vault.this.name
}

output "backup_vault_arn" {
  description = "The ARN of the AWS Backup vault created."
  value       = aws_backup_vault.this.arn
}
