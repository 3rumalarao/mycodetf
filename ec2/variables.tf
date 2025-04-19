variable "instances" {
  description = "Map of instance configs"
  type = map(object({
    ami             = string
    instance_type   = string
    subnet_index    = number
    key_name        = string
    security_groups = list(string)
  }))
}

variable "private_subnets" { type = list(string) }
variable "public_subnets"  { type = list(string) }
variable "is_public"      { type = bool }
variable "env"            { type = string }
variable "orgname"        { type = string }
variable "common_tags"    { type = map(string) }
variable "sg_dependency"  { type = any }
