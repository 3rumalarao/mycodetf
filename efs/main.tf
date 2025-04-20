resource "aws_efs_file_system" "this" {
  creation_token = var.name # Ensures idempotency

  # Optional Configuration
  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode
  provisioned_throughput_in_mibps = var.throughput_mode == "provisioned" ? var.provisioned_throughput_in_mibps : null
  encrypted        = var.encrypted
  kms_key_id       = var.encrypted ? var.kms_key_id : null # Only relevant if encrypted

  # Add lifecycle_policy block if managing lifecycle rules

  tags = merge(var.common_tags, {
    Name        = var.name
    Environment = var.environment
  })
}

resource "aws_efs_mount_target" "this" {
  # Use AZ from input object as the key for better clarity if needed later,
  # though index is still used for subnet lookup.
  for_each = { for mt in var.mount_targets : mt.az => mt }

  file_system_id = aws_efs_file_system.this.id

  # Subnet selection using index. Limitation: Sensitive to order of var.private_subnets.
  subnet_id = var.private_subnets[each.value.subnet_index]

  # Assign the resolved Security Group IDs passed from the root module
  security_groups = var.security_groups

  # Mount targets themselves cannot be tagged directly via this resource.
  # Tags apply to the associated Elastic Network Interface (ENI) automatically.
}
