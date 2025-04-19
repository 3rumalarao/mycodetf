variable "lb" {
  type = object({
    name            = string
    type            = string
    scheme          = string
    listener_port   = number
    security_groups = list(string)
  })
}

variable "subnet_ids" { type = list(string) }
variable "vpc_id"     { type = string }
variable "common_tags"{ type = map(string) }
