variable "ssm_parameters" {
  description = "Map of SSM parameters to create. Keys are logical identifiers used in the for_each loop."
  type = map(object({
    name        = string # The full name/path for the SSM parameter (e.g., /dev/sap/db/mysql/ip)
    description = optional(string, "Managed by Terraform")
    value       = any    # The value for the parameter (can be string or list for StringList)
    type        = string # Parameter type: String, SecureString, or StringList
    key_id      = optional(string) # KMS Key ID or ARN for SecureString type. If null, uses default AWS-managed key.
    # Add tier, data_type etc. if needed
  }))
  default = {}
}

variable "common_tags" {
  description = "Common tags to apply to the SSM parameters."
  type        = map(string)
  default     = {}
}

variable "overwrite_existing_parameters" {
  description = "Whether to overwrite existing SSM parameters with the same name."
  type        = bool
  default     = true # Default to true, assuming Terraform is the source of truth
}
