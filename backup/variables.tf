variable "backup_policy" {
  type = object({ retention_days:number, resource_tag_filter:string })
}
