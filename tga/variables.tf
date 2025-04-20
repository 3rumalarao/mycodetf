variable "target_group_arn" {
  description = "ARN of the Target Group to which targets will be registered."
  type        = string
}

variable "targets" {
  description = "List of target objects to register. Each object must have 'id' (instance ID, IP address, etc.) and 'port'."
  type        = list(object({
    id   = string
    port = number
  }))
  default = [] # Default to empty list to avoid errors if no targets are provided
}
