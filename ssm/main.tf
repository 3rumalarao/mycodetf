resource "aws_ssm_parameter" "this" {
  for_each = var.ssm_parameters

  name        = each.value.name
  description = each.value.description
  # Ensure value is converted to string, as SSM API expects string even for StringList
  value       = each.value.type == "StringList" ? join(",", each.value.value) : tostring(each.value.value)
  type        = each.value.type
  key_id      = each.value.type == "SecureString" ? each.value.key_id : null # Only applies to SecureString

  # REMOVED: overwrite = var.overwrite_existing_parameters - Deprecated, default behavior is to update.

  # Apply tags
  tags = merge(var.common_tags, {
    Name = each.value.name # Use the full parameter name/path as the Name tag
  })
}
