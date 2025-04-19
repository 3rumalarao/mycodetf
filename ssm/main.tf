resource "aws_ssm_parameter" "this" {
  for_each    = var.ssm_parameters
  name        = each.value.name
  description = each.value.description
  value       = each.value.value
  type        = each.value.type
  overwrite   = true
}
