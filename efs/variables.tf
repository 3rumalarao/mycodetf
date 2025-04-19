variable "name"            { type = string }
variable "mount_targets"   { type = list(object({ az:string, subnet_index:number })) }
variable "private_subnets" { type = list(string) }
variable "vpc_id"          { type = string }
variable "environment"     { type = string }
variable "common_tags"     { type = map(string) }
variable "security_groups" { type = list(string) }
