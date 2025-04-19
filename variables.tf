variable "aws_region"    { type = string }
variable "env"           { type = string }
variable "orgname"       { type = string }
variable "vpc_id"        { type = string }
variable "private_subnets"{ type = list(string) }
variable "public_subnets" { type = list(string) }
variable "private_servers"{ type = map(object({ ami:string, instance_type:string, subnet_index:number, key_name:string, security_groups=list(string) })) }
variable "public_servers" { type = map(object({ ami:string, instance_type:string, subnet_index:number, key_name:string, allocate_eip:bool, security_groups=list(string) })) }
variable "application_servers"{
  type = map(object({
    instances = map(object({
      ami:string, instance_type:string, subnet_index:number, key_name:string, az:string, security_groups=list(string)
    })),
    lb = object({ name:string, type:string, scheme:string, listener_port:number, security_groups=list(string) })
  }))
}
variable "rds_config"    { type = object({ name:string, instance_class:string, engine:string, storage:number }) }
variable "db_username"   { type = string }
variable "db_password"   { type = string }
variable "rds_security_groups" { type = list(string) }
variable "efs"           { type = object({ name:string, mount_targets:list(object({ az:string, subnet_index:number })) }) }
variable "ssm_parameters"{ type = map(object({ name:string, description:string, value:any, type:string })) }
variable "backup_policy" { type = object({ retention_days:number, resource_tag_filter:string }) }
variable "common_tags"   { type = map(string) }
variable "security_groups"{ type = map(object({ name:string, description:string, ingress:list(object({from_port:number,to_port:number,protocol:string,cidr_blocks:list(string)})), egress:list(object({from_port:number,to_port:number,protocol:string,cidr_blocks:list(string)})) })) }
variable "instance_to_sg"{ type = map(string) }
