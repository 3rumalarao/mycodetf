resource "aws_efs_file_system" "this" {
  creation_token = var.name
  tags = merge(var.common_tags, { Name = var.name, Environment = var.environment })
}

resource "aws_efs_mount_target" "this" {
  for_each         = { for i, mt in var.mount_targets : i => mt }
  file_system_id   = aws_efs_file_system.this.id
  subnet_id        = var.private_subnets[each.value.subnet_index]
  security_groups  = var.security_groups
}
