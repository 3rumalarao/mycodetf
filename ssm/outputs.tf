output "ssm_parameters" {
  description = "Map of the created AWS SSM Parameter resources, keyed by the logical identifiers from the input variable."
  value       = aws_ssm_parameter.this
}

output "ssm_parameter_names" {
  description = "Map of the logical identifiers to the actual SSM parameter names created."
  value       = { for k, p in aws_ssm_parameter.this : k => p.name }
}

output "ssm_parameter_arns" {
  description = "Map of the logical identifiers to the ARNs of the SSM parameters created."
  value       = { for k, p in aws_ssm_parameter.this : k => p.arn }
}
