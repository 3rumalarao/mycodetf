

variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources (e.g., 'us-east-1')."
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "Must be a valid AWS region name (e.g., us-east-1)."
  }
}

variable "env" {
  type        = string
  description = "Deployment environment name (e.g., 'dev', 'stg', 'prod'). Used for naming and conditional logic."
  validation {
    condition     = contains(["dev", "stg", "qa", "prod"], var.env)
    error_message = "Environment must be one of: dev, stg, qa, prod."
  }
}

variable "orgname" {
  type        = string
  description = "Organization name, used as a prefix for resource names (e.g., 'sap')."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where resources will be deployed (provided by CCOE)."
  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "VPC ID must start with 'vpc-'."
  }
}

variable "private_subnets" {
  type        = list(string)
  description = "A list of private subnet IDs within the VPC (provided by CCOE)."
  validation {
    condition     = length(var.private_subnets) > 0
    error_message = "At least one private subnet ID must be provided."
  }
  validation {
     condition     = alltrue([for s in var.private_subnets : can(regex("^subnet-", s))])
     error_message = "All private subnet IDs must start with 'subnet-'."
  }
}

variable "public_subnets" {
  type        = list(string)
  description = "A list of public subnet IDs within the VPC (provided by CCOE)."
   validation {
    condition     = length(var.public_subnets) > 0
    error_message = "At least one public subnet ID must be provided."
  }
   validation {
     condition     = alltrue([for s in var.public_subnets : can(regex("^subnet-", s))])
     error_message = "All public subnet IDs must start with 'subnet-'."
  }
}

variable "private_servers" {
  type = map(object({
    ami             = string       # Specific AMI ID for the instance
    instance_type   = string       # EC2 instance type (e.g., t3.micro)
    subnet_index    = number       # Index into var.private_subnets list
    key_name        = string       # Name of the EC2 Key Pair for SSH access
    security_groups = list(string) # List of logical SG *keys* referencing the 'security_groups' map
  }))
  description = "Map defining configurations for private utility EC2 instances. Keys are logical instance names (e.g., 'mysql')."
  default     = {}
}

variable "public_servers" {
  type = map(object({
    ami             = string       # Specific AMI ID for the instance
    instance_type   = string       # EC2 instance type
    subnet_index    = number       # Index into var.public_subnets list
    key_name        = string       # Name of the EC2 Key Pair for SSH access
    allocate_eip    = bool         # Whether to allocate an Elastic IP (requires logic in EC2 module)
    security_groups = list(string) # List of logical SG *keys* referencing the 'security_groups' map
  }))
  description = "Map defining configurations for public EC2 instances (e.g., bastion, regcom). Keys are logical instance names."
  default     = {}
}

# /Users/tirumal/Downloads/chatgpt/mycodetf-main/variables.tf

variable "application_servers" {
  type = map(object({
    # --- Instance Definitions ---
    instances = map(object({
      ami             = string       # Specific AMI ID for the instance
      instance_type   = string       # EC2 instance type
      subnet_index    = number       # Index into var.private_subnets list (assuming app instances are private)
      key_name        = string       # Name of the EC2 Key Pair for SSH access
      az              = string       # Specific Availability Zone (e.g., 'us-east-1a')
      security_groups = list(string) # List of logical SG *keys* referencing the 'security_groups' map
    }))
    # --- Load Balancer Definition (Optional) ---
    lb = optional(object({
      name            = string       # Base name for LB/TG resources
      type            = string       # "application" or "network"
      scheme          = string       # "internal" or "internet-facing"
      listener_port   = number       # Port for the listener
      # --- CORRECTED: Made security_groups optional ---
      security_groups = optional(list(string), []) # List of logical SG *keys* (only used for type="application")
      # --- Optional Health Check ---
      health_check = optional(object({
        path                = optional(string, "/") # HC Path for ALBs
        interval            = optional(number, 30)
        timeout             = optional(number, 5)
        healthy_threshold   = optional(number, 3)
        unhealthy_threshold = optional(number, 3)
        matcher             = optional(string, "200") # HC Matcher for ALBs
      }), {}) # Default to empty object for health check
      # Add other optional LB settings from loadbalancer module variables if needed
    }))
  }))
  description = "Map defining application tiers. Keys are application names (e.g., 'crm'). Each tier has instances and an optional load balancer."
  default     = {}
}

variable "rds_config" {
  type = object({
    name           = string # Logical name for RDS instance/cluster
    instance_class = string # e.g., 'db.t3.medium'
    engine         = string # e.g., 'mysql', 'postgres'
    engine_version = optional(string, null) # Specify engine version (e.g., "8.0.28" for mysql)
    storage        = number # Storage size in GB
    # Add other optional fields matching rds module variables if needed (multi_az, etc.)
  })
  description = "Configuration object for the RDS database instance."
}

variable "db_username" {
  type        = string
  description = "Master username for the RDS database. Consider fetching from secrets manager."
}

variable "db_password" {
  type        = string
  description = "Master password for the RDS database. DO NOT commit plain text passwords. Fetch from secrets manager or use TF_VAR_db_password env var."
  sensitive   = true # CRITICAL: Mark password as sensitive
}

variable "rds_security_groups" {
  type        = list(string)
  description = "List of logical security group *keys* (referencing 'security_groups' map) to attach to the RDS instance."
  default     = []
}

variable "efs" {
  type = object({
    name          = string # Name for the EFS file system
    mount_targets = list(object({
      az           = string # AZ for the mount target
      subnet_index = number # Index into var.private_subnets for the mount target
    }))
    # Add other optional fields matching efs module variables if needed (performance_mode, etc.)
  })
  description = "Configuration for the EFS file system and its mount targets."
}

variable "ssm_parameters" {
  type = map(object({
    description = optional(string, "Managed by Terraform")
    type        = string # e.g., 'String', 'SecureString', 'StringList'
    key_id      = optional(string) # KMS Key ID/ARN for SecureString
    # 'name' and 'value' are constructed/looked up dynamically in locals.tf
  }))
  description = "Map defining SSM parameters to create. Keys are logical names used for dynamic value lookup and name construction."
  default     = {}
}

variable "backup_policy" {
  type = object({
    retention_days      = number # How long to keep backups
    resource_tag_filter = string # The VALUE of the tag used to select resources (e.g., "prod-backup")
    resource_tag_key    = string # The KEY of the tag used to select resources (e.g., "Backup")
    schedule            = string # Cron expression for the backup schedule (e.g., "cron(0 5 * * ? *)")
  })
  description = "Configuration for the AWS Backup plan (only applied in 'prod' env)."
  # No default needed as it's only used when count > 0
}

variable "common_tags" {
  type        = map(string)
  description = "Map of common tags to apply to all taggable resources."
  default     = {}
}

variable "security_groups" {
  description = "Map defining security groups. Keys are logical names used for referencing."
  type = map(object({
    name        = string # The actual base name for the SG resource (e.g., "dev-sap-crm-sg")
    description = string
    ingress = list(object({
      description       = optional(string)
      from_port         = number
      to_port           = number
      protocol          = string
      # --- Specify ONE source type ---
      cidr_blocks       = optional(list(string))
      ipv6_cidr_blocks  = optional(list(string))
      prefix_list_ids   = optional(list(string))
      # Use keys here in tfvars, locals.tf will resolve to IDs for the module if needed
      # Or adjust SG module to handle keys directly (more complex)
      # For simplicity with separate aws_security_group_rule, stick to keys/CIDRs here.
      # If using the updated SG module expecting IDs:
      # source_security_group_id = optional(string) # This would require pre-resolved IDs in tfvars - less ideal
      # Let's assume for now the SG module handles keys OR we use separate rule resources
      source_security_group_keys = optional(list(string)) # Use keys here
      self                       = optional(bool)
    }))
    egress = list(object({
      description       = optional(string)
      from_port         = number
      to_port           = number
      protocol          = string
      # --- Specify ONE destination type ---
      cidr_blocks       = optional(list(string))
      ipv6_cidr_blocks  = optional(list(string))
      prefix_list_ids   = optional(list(string))
      # destination_security_group_id = optional(string) # See comment above
      destination_security_group_keys = optional(list(string)) # Use keys here
      self                            = optional(bool)
    }))
  }))
  default = {}
  # NOTE: The structure here assumes the SG module can handle resolving 'source_security_group_keys'
  # or that separate aws_security_group_rule resources are used in main.tf.
  # If the SG module strictly requires resolved IDs in its input rules, this definition
  # and the corresponding .tfvars structure would need significant changes.
}

variable "instance_to_sg" {
  type        = map(string)
  description = "Optional map to link a logical instance name (key) to a different logical security group key (value). Used during SG ID resolution in locals.tf."
  default     = {}
}


# ADDED: Variable for the existing IAM Role name
variable "existing_common_ec2_role_name" {
  type        = string
  description = "The name of the existing IAM Role to attach to EC2 instances."
}


variable "existing_common_ec2_profile_name" {
  type        = string
  description = "The name of the existing IAM Role to attach to EC2 instances."
}

variable "schedule_tag_key" {
  description = "Tag key used to identify resources for scheduled start/stop."
  type        = string
  default     = "AutoStartStop"
}

variable "schedule_tag_value" {
  description = "Tag value used to identify resources for scheduled start/stop."
  type        = string
  default     = "true"
}

variable "schedule_start_cron" {
  description = "Cron expression for starting resources (UTC recommended unless using timezone)."
  type        = string
  # Example: 7 AM America/Chicago (12:00 UTC during standard time, 11:00 UTC during daylight time)
  # Use UTC for simplicity: 'cron(12 0 * * ? *)' for 12:00 UTC
  default     = "cron(12 0 * * ? *)" # 12:00 UTC (adjust as needed)
}

variable "schedule_stop_cron" {
  description = "Cron expression for stopping resources (UTC recommended unless using timezone)."
  type        = string
  # Example: 5 PM America/Chicago (22:00 UTC during standard time, 21:00 UTC during daylight time)
  # Use UTC for simplicity: 'cron(22 0 * * ? *)' for 22:00 UTC
  default     = "cron(22 0 * * ? *)" # 22:00 UTC (adjust as needed)
}

variable "schedule_timezone" {
  description = "Optional: IANA timezone name for the cron schedule (e.g., America/Chicago). If omitted or empty, UTC is assumed by EventBridge."
  type        = string
  default     = "" # Default to UTC for simplicity unless timezone handling is critical
}

variable "notification_email" {
  description = "Email address to send start/stop notifications."
  type        = string
  # No default - This MUST be provided by the user
}

variable "lambda_timeout_seconds" {
  description = "Timeout for the Lambda function in seconds."
  type        = number
  default     = 300 # Increased default (5 mins) for RDS operations and status checks
}

variable "log_retention_days" {
  description = "Number of days to retain Lambda logs in CloudWatch."
  type        = number
  default     = 14
}
