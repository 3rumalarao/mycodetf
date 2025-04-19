variable "rds_config" {
  type = object({ name:string, instance_class:string, engine:string, storage:number })
}
variable "privates_subnets" { type = list(string) }
variable "environment"      { type = string }
variable "db_username"     { type = string }
variable "db_password"     { type = string }
variable "common_tags"     { type = map(string) }
variable "rds_security_groups" { type = list(string) }
