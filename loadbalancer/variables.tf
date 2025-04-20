variable "lb_config" { # Renamed from "lb" for clarity, as it now includes more than just LB settings
  description = "Configuration object for the Load Balancer, Listener, and Target Group."
  type = object({
    # --- Required ---
    name            = string # Base name for LB, TG, Listener
    type            = string # "application" or "network"
    scheme          = string # "internal" or "internet-facing"
    listener_port   = number # Port for Listener and Target Group

    # --- Optional / Contextual ---
    # List of resolved Security Group IDs (Required ONLY for type="application")
    security_group_ids = optional(list(string), [])

    # --- Target Group Settings ---
    target_type      = optional(string, "instance") # instance, ip, lambda
    health_check = optional(object({
      enabled             = optional(bool, true)
      interval            = optional(number, 30)
      path                = optional(string, "/") # Required for HTTP/HTTPS checks (ALB)
      port                = optional(string, "traffic-port")
      protocol            = optional(string) # HTTP, HTTPS, TCP, TLS, GENEVE. Defaults based on TG protocol.
      timeout             = optional(number, 5)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
      matcher             = optional(string, "200") # HTTP codes for success (e.g., "200,302")
    }), {}) # Default to empty object, allowing partial overrides

    deregistration_delay = optional(number, 300) # Seconds

    # --- Listener Settings ---
    listener_protocol = optional(string) # HTTP, HTTPS, TCP, TLS, UDP, TCP_UDP, GENEVE. Defaults based on LB type/port.
    certificate_arn   = optional(string) # Required for HTTPS/TLS listeners
    ssl_policy        = optional(string) # Relevant for HTTPS/TLS listeners (e.g., "ELBSecurityPolicy-2016-08")

    # --- LB Settings ---
    enable_deletion_protection = optional(bool, false)
    idle_timeout               = optional(number, 60)
    # access_logs block can be added here if needed
  })
}

variable "subnet_ids" {
  description = "List of subnet IDs to attach the Load Balancer to."
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where the Load Balancer and Target Group will be created."
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to the Load Balancer resources."
  type        = map(string)
  default     = {}
}
