variable "backup_policy" {
  description = "Configuration for the backup plan, including retention, schedule, and tag-based selection criteria."
  type = object({
    retention_days      = number
    resource_tag_filter = string # The VALUE of the tag to filter resources on (e.g., "prod-backup" or "prod")
    resource_tag_key    = string # The KEY of the tag to filter resources on (e.g., "Backup" or "Environment")
    schedule            = string # Cron expression for the backup schedule (e.g., "cron(0 5 * * ? *)")
  })
  # No default, as this should be provided explicitly for the prod environment where the module is active.
}

variable "common_tags" {
  description = "Common tags to apply to backup resources."
  type        = map(string)
  default     = {}
}
