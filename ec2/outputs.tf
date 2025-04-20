output "instance_ids" {
  description = "Map of logical instance names to their AWS Instance IDs."
  value       = { for k, inst in aws_instance.this : k => inst.id }
}

output "private_ips" {
  description = "Map of logical instance names to their Private IP addresses."
  value       = { for k, inst in aws_instance.this : k => inst.private_ip }
}

output "public_ips" {
  description = "Map of logical instance names to their Public IP addresses (if applicable, often EIP)."
  # Note: This will be null if no public IP/EIP is assigned.
  # If using separate aws_eip resource, output eip.public_ip instead.
  value = { for k, inst in aws_instance.this : k => inst.public_ip }
}

# ADDED: Instance ARNs output
output "instance_arns" {
  description = "Map of logical instance names to their AWS Instance ARNs."
  value       = { for k, inst in aws_instance.this : k => inst.arn }
}
