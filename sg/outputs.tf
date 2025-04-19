output "sg_ids" {
  description = "Map of SG IDs keyed by definition key"
  value       = { for k, sg in aws_security_group.this : k => sg.id }
}
