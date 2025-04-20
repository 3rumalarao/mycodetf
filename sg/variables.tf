variable "security_groups" {
  description = "Map of Security Group definitions. Keys are logical names used for referencing."
  type = map(object({
    name        = string # The desired base name for the SG (e.g., "dev-sap-crm-sg")
    description = string
    # --- Updated Rule Structure ---
    ingress = list(object({
      description       = optional(string) # Description for the specific rule
      from_port         = number
      to_port           = number
      protocol          = string # e.g., 'tcp', 'udp', 'icmp', '-1' (all)
      # --- Specify ONE source type ---
      cidr_blocks       = optional(list(string))
      ipv6_cidr_blocks  = optional(list(string))
      prefix_list_ids   = optional(list(string))
      # CHANGED: Changed from security_group_keys to source_security_group_id
      # Allow referencing ONE other SG ID as a source
      source_security_group_id = optional(string)
      self              = optional(bool)
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
      # CHANGED: Added destination_security_group_id for egress rules targeting another SG
      destination_security_group_id = optional(string)
      self              = optional(bool) # Less common for egress
    }))
  }))
  default = {}
}

variable "vpc_id" {
  description = "VPC ID where SGs will be created."
  type        = string
}

# ADDED: Common Tags input
variable "common_tags" {
  description = "Common tags to apply to all security groups."
  type        = map(string)
  default     = {}
}
