variable "ssm_parameters" {
  type = map(object({ name:string, description:string, value:any, type:string }))
}
