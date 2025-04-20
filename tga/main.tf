resource "aws_lb_target_group_attachment" "this" {
  # Use index as key for robustness, handles potential duplicate target IDs if ever applicable
  for_each = { for idx, t in var.targets : idx => t }

  target_group_arn = var.target_group_arn
  target_id        = each.value.id
  port             = each.value.port

  # No explicit depends_on needed here, as dependencies are implicitly handled
  # by the source of var.target_group_arn and each.value.id in the calling module.
}
