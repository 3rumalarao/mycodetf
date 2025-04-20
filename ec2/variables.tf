variable "instances" {
  description = "Map of instance configurations. Keys are logical instance names."
  type = map(object({
    ami                = string
    instance_type      = string
    subnet_index       = number # Index into subnet list (private or public based on is_public)
    key_name           = string
    # CHANGED: Expect resolved Security Group IDs, not keys/names
    security_group_ids = list(string)
    # Optional: Add AZ if subnet selection logic is enhanced later
    az                 = optional(string)
    # Optional: Add user_data, ebs_volumes, etc. if needed
  }))
}

variable "private_subnets" {
  description = "List of private subnet IDs available for instance placement."
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet IDs available for instance placement."
  type        = list(string)
}

variable "is_public" {
  description = "If true, place instances in public subnets and potentially allocate EIPs (module logic dependent). If false, use private subnets."
  type        = bool
}

variable "env" {
  description = "Deployment environment name (e.g., 'dev')."
  type        = string
}

variable "orgname" {
  description = "Organization name, used in resource naming."
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all taggable resources created by this module."
  type        = map(string)
  default     = {}
}

# REMOVED: sg_dependency variable is no longer needed.
# variable "sg_dependency"  { type = any }
