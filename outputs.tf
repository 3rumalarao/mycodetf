# /Users/tirumal/Downloads/chatgpt/mycodetf-main/outputs.tf

output "private_instance_ids" {
  description = "Map of logical names to instance IDs for private utility servers (e.g., mysql, postgresql)."
  value       = module.private_ec2.instance_ids
}

output "private_instance_ips" {
  description = "Map of logical names to private IP addresses for private utility servers."
  value       = module.private_ec2.private_ips
}

output "public_instance_ids" {
  description = "Map of logical names to instance IDs for public servers (e.g., regcom, ercot)."
  value       = module.public_ec2.instance_ids
}

output "public_instance_ips" {
  description = "Map of logical names to public IP addresses (EIPs) for public servers."
  value       = module.public_ec2.public_ips # Assumes EC2 module outputs EIPs correctly if allocated
}

output "application_instance_ids" {
  description = "Map of application names to maps of their instance IDs (e.g., {'crm'={'crm1'='i-...', 'crm2'='i-...'}})."
  value       = { for k, v in module.app_ec2 : k => v.instance_ids }
}

output "application_instance_ips" {
  description = "Map of application names to maps of their private instance IPs."
  value       = { for k, v in module.app_ec2 : k => v.private_ips }
}

output "application_lb_dns_names" {
  description = "Map of application names to their load balancer DNS names."
  value       = { for k, v in module.app_lb : k => v.lb_dns }
}

output "efs_id" {
  description = "The ID of the EFS file system."
  value       = module.efs.efs_id
}

output "efs_arn" {
  description = "The ARN of the EFS file system."
  value       = module.efs.efs_arn # Assumes EFS module outputs this
}

output "rds_endpoint" {
  description = "Connection endpoint address for the RDS database instance."
  value       = module.rds.rds_endpoint
}

output "rds_arn" {
  description = "ARN of the RDS database instance."
  value       = module.rds.rds_arn # Assumes RDS module outputs this
}

output "ssm_parameter_names" {
  description = "Map of logical parameter keys to the full SSM parameter names created."
  value       = module.ssm.ssm_parameter_names # Assumes SSM module outputs this map
}

output "backup_plan_id" {
  description = "The ID of the AWS Backup plan created (empty string if not created, e.g., in non-prod)."
  value       = length(module.backup) > 0 ? module.backup[0].backup_plan_id : ""
}

output "sg_ids" {
  description = "Map of logical security group names to their AWS IDs."
  value       = module.sg.sg_ids
}
