output "efs_id" {
  description = "The ID of the created EFS file system."
  value       = aws_efs_file_system.this.id
}

output "efs_arn" {
  description = "The ARN of the created EFS file system."
  value       = aws_efs_file_system.this.arn
}

# Optional: Output mount target IPs if needed
# output "mount_target_ips" {
#   description = "Map of Availability Zone to Mount Target IP Address."
#   value       = { for az, mt in aws_efs_mount_target.this : az => mt.ip_address }
# }
