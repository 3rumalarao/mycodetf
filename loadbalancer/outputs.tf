output "lb_dns" {
  description = "DNS name of the created Load Balancer."
  value       = aws_lb.this.dns_name
}

output "lb_arn" {
  description = "ARN of the created Load Balancer."
  value       = aws_lb.this.arn
}

output "lb_zone_id" {
  description = "Route 53 Hosted Zone ID for the Load Balancer (useful for alias records)."
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "ARN of the created Target Group."
  value       = aws_lb_target_group.this.arn
}

output "target_group_name" {
  description = "Name of the created Target Group."
  value       = aws_lb_target_group.this.name
}

output "listener_arn" {
  description = "ARN of the created Listener."
  value       = aws_lb_listener.this.arn
}
