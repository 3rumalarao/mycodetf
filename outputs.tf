output "private_instance_ids" {
  description = "Map of logical names to instance IDs for private utility servers (e.g., mysql, postgresql)."
  value       = module.private_ec2.instance_ids
  # ACTION: Verify ./ec2/outputs.tf defines 'instance_ids'
}

output "private_instance_ips" {
  description = "Map of logical names to private IP addresses for private utility servers."
  value       = module.private_ec2.private_ips
  # ACTION: Verify ./ec2/outputs.tf defines 'private_ips'
}

output "public_instance_ids" {
  description = "Map of logical names to instance IDs for public servers (e.g., regcom, ercot)."
  value       = module.public_ec2.instance_ids
  # ACTION: Verify ./ec2/outputs.tf defines 'instance_ids'
}

output "public_instance_ips" {
  description = "Map of logical names to public IP addresses (EIPs) for public servers."
  value       = module.public_ec2.public_ips
  # ACTION: Verify ./ec2/outputs.tf defines 'public_ips'
}

# --- CORRECTED Application Outputs ---

output "application_instance_ids" {
  description = "Map of application names to maps of their instance IDs (e.g., {'crm'={'crm1'='i-...', 'crm2'='i-...'}})."
  value = {
    crm         = module.crm_ec2.instance_ids
    clover      = module.clover_ec2.instance_ids
    ldaphaproxy = module.ldaphaproxy_ec2.instance_ids
    # ACTION: Verify ./ec2/outputs.tf defines 'instance_ids'
  }
}

output "application_instance_ips" {
  description = "Map of application names to maps of their private instance IPs."
  value = {
    crm         = module.crm_ec2.private_ips
    clover      = module.clover_ec2.private_ips
    ldaphaproxy = module.ldaphaproxy_ec2.private_ips
    # ACTION: Verify ./ec2/outputs.tf defines 'private_ips'
  }
}

output "application_lb_dns_names" {
  description = "Map of application names to their load balancer DNS names."
  value = {
    crm         = module.crm_lb.lb_dns
    clover      = module.clover_lb.lb_dns
    ldaphaproxy = module.ldaphaproxy_lb.lb_dns
    # ACTION: Verify ./loadbalancer/outputs.tf defines 'lb_dns'
  }
}

# --- Other Outputs ---

output "efs_id" {
  description = "The ID of the EFS file system."
  value       = module.efs.efs_id
  # ACTION: Verify ./efs/outputs.tf defines 'efs_id'
}

output "efs_arn" {
  description = "The ARN of the EFS file system."
  value       = module.efs.efs_arn
  # ACTION: Verify ./efs/outputs.tf defines 'efs_arn'
}

output "rds_endpoint" {
  description = "Connection endpoint address for the RDS database instance."
  value       = module.rds.rds_endpoint
  # ACTION: Verify ./rds/outputs.tf defines 'rds_endpoint'
}

output "rds_arn" {
  description = "ARN of the RDS database instance."
  value       = module.rds.rds_arn
  # ACTION: Verify ./rds/outputs.tf defines 'rds_arn'
}

output "ssm_parameter_names" {
  description = "Map of logical parameter keys to the full SSM parameter names created."
  value       = module.ssm.ssm_parameter_names
  # ACTION: Verify ./ssm/outputs.tf defines 'ssm_parameter_names'
}

output "backup_plan_id" {
  description = "The ID of the AWS Backup plan created (empty string if not created, e.g., in non-prod)."
  value       = length(module.backup) > 0 ? module.backup[0].backup_plan_id : ""
  # ACTION: Verify ./backup/outputs.tf defines 'backup_plan_id'
}

output "sg_ids" {
  description = "Map of logical security group names to their AWS IDs."
  value       = module.sg.sg_ids
  # ACTION: Verify ./sg/outputs.tf defines 'sg_ids'
}
