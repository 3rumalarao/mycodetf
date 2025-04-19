variable "security_groups" {
  description = "Map of SG definitions"
  type = map(object({
    name        = string
    description = string
    ingress     = list(object({ from_port:number, to_port:number, protocol:string, cidr_blocks:list(string) }))
    egress      = list(object({ from_port:number, to_port:number, protocol:string, cidr_blocks:list(string) }))
  }))
}

variable "vpc_id" {
  description = "VPC ID where SGs will be created"
  type        = string
}
