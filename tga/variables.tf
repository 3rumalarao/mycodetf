variable "target_group_arn" { type = string }
variable "targets" { type = list(object({ id:string, port:number })) }
