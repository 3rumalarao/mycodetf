
output "instance_ids" {
  description = "Map of logical instance names to their AWS Instance IDs."
  value       = { for k, inst in aws_instance.this : k => inst.id }
  # Assumes your instance resource is named aws_instance.this and uses for_each
}

output "private_ips" {
  description = "Map of logical instance names to their Private IP addresses."
  value       = { for k, inst in aws_instance.this : k => inst.private_ip }
  # Assumes your instance resource is named aws_instance.this and uses for_each
}

output "public_ips" {
  description = "Map of logical instance names to their Public IP addresses (if applicable, often EIP)."
  # Note: This will be null if no public IP/EIP is assigned.
  # If using separate aws_eip resource, output eip.public_ip instead.
  value = { for k, inst in aws_instance.this : k => inst.public_ip }
  # Assumes your instance resource is named aws_instance.this and uses for_each
}

output "instance_arns" {
  description = "Map of logical instance names to their AWS Instance ARNs."
  value       = { for k, inst in aws_instance.this : k => inst.arn }
  # Assumes your instance resource is named aws_instance.this and uses for_each
}
