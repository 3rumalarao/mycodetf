variable "name" {
  description = "Name for the EFS file system (used for creation token and Name tag)."
  type        = string
}

variable "mount_targets" {
  description = "List of mount target configurations. Each object requires 'az' and 'subnet_index'."
  type        = list(object({
    az           = string # Availability Zone for the mount target
    subnet_index = number # Index into the private_subnets list
  }))
}

variable "private_subnets" {
  description = "List of private subnet IDs where mount targets can be created."
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where the EFS file system resides (unused currently but good for context)."
  type        = string
}

variable "environment" {
  description = "Deployment environment name (e.g., 'dev'), used for tagging."
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to the EFS file system."
  type        = map(string)
  default     = {}
}

variable "security_groups" {
  description = "List of Security Group IDs to associate with the EFS mount targets."
  type        = list(string)
  # This list should contain resolved SG IDs passed from the calling module.
}

# --- Optional EFS Configuration ---

variable "performance_mode" {
  description = "The performance mode of the file system (e.g., 'generalPurpose' or 'maxIO')."
  type        = string
  default     = "generalPurpose"
  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.performance_mode)
    error_message = "Performance mode must be either 'generalPurpose' or 'maxIO'."
  }
}

variable "throughput_mode" {
  description = "Throughput mode for the file system (e.g., 'bursting' or 'provisioned')."
  type        = string
  default     = "bursting"
  validation {
    condition     = contains(["bursting", "provisioned"], var.throughput_mode)
    error_message = "Throughput mode must be either 'bursting' or 'provisioned'."
  }
}

variable "provisioned_throughput_in_mibps" {
  description = "The throughput, measured in MiB/s, that you want to provision for a file system that uses 'provisioned' throughput mode. Required if throughput_mode is 'provisioned'."
  type        = number
  default     = null # Set only if throughput_mode is 'provisioned'
}

variable "encrypted" {
  description = "If true, the file system will be encrypted."
  type        = bool
  default     = true # Recommended to default to encrypted
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. Required if 'encrypted' is true and using a customer-managed key."
  type        = string
  default     = null # Defaults to AWS-managed key if encrypted=true and this is null
}

# Add lifecycle_policy variable if needed
