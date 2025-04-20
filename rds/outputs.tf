output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance."
  value       = aws_db_instance.this.endpoint
}

output "rds_arn" {
  description = "The ARN of the RDS instance."
  value       = aws_db_instance.this.arn
}

output "rds_resource_id" {
  description = "The region-unique, immutable identifier for the RDS instance."
  value       = aws_db_instance.this.resource_id
}

output "rds_hosted_zone_id" {
  description = "The Route53 Hosted Zone ID of the endpoint."
  value       = aws_db_instance.this.hosted_zone_id
}

output "rds_port" {
  description = "The port on which the DB accepts connections."
  value       = aws_db_instance.this.port
}
