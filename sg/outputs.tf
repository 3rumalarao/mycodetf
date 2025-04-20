output "sg_ids" {
  description = "Map of logical security group names (keys from input variable) to their AWS IDs."
  value       = { for k, sg in aws_security_group.this : k => sg.id }
}
