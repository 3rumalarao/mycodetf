variable "rds_config" {
  description = "Core configuration for the RDS instance."
  type = object({
    name           = string # Logical name used for naming resources
    instance_class = string # e.g., db.t3.medium
    engine         = string # e.g., mysql, postgres
    engine_version = optional(string) # Specify engine version (e.g., "8.0.28" for mysql)
    storage        = number # Storage size in GB
  })
}

variable "private_subnets" { # CORRECTED Typo: Removed trailing 's'
  description = "List of private subnet IDs for the DB Subnet Group."
  type        = list(string)
}

variable "environment" {
  description = "Deployment environment name (e.g., 'dev'), used for tagging."
  type        = string
}

variable "db_username" {
  description = "Master username for the RDS database."
  type        = string
  # Sensitive might be appropriate depending on policy, but password is more critical
  # sensitive   = true
}

variable "db_password" {
  description = "Master password for the RDS database. HIGHLY RECOMMENDED to fetch from a secure source (Secrets Manager, SSM SecureString) or use TF_VAR env var, not plain text tfvars."
  type        = string
  sensitive   = true # ADDED: Mark password as sensitive
}

variable "common_tags" {
  description = "Common tags to apply to RDS resources."
  type        = map(string)
  default     = {}
}

variable "rds_security_groups" {
  description = "List of Security Group IDs to associate with the RDS instance. Should be resolved IDs."
  type        = list(string)
}

# --- Optional RDS Configuration ---

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ."
  type        = bool
  default     = false # Default to false for dev, override to true for prod
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted."
  type        = bool
  default     = true # Recommended default
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. If encrypted is true and this is null, the default AWS KMS key is used."
  type        = string
  default     = null
}

variable "backup_retention_period" {
  description = "Days to retain backups for."
  type        = number
  default     = 7 # Example default
}

variable "backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Eg: '04:00-06:00'."
  type        = string
  default     = "04:00-06:00" # Example default
}

variable "maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'."
  type        = string
  default     = "Mon:00:00-Mon:03:00" # Example default
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. Set to true for dev/test, false for prod."
  type        = bool
  default     = true # Default to true for non-prod safety, override to false for prod
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true."
  type        = bool
  default     = false # Default to false for dev, override to true for prod
}

variable "parameter_group_name" {
  description = "Name of the DB parameter group to associate."
  type        = string
  default     = null # Uses default parameter group if null
}

variable "option_group_name" {
  description = "Name of the DB option group to associate."
  type        = string
  default     = null # Uses default option group if null
}

variable "publicly_accessible" {
  description = "Bool to control if instance is publicly accessible."
  type        = bool
  default     = false # Should almost always be false for databases
}

# Add other variables like performance_insights_enabled, iam_database_authentication_enabled etc. if needed
