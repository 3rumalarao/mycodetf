resource "aws_lb_target_group_attachment" "this" {
  for_each = { for idx, t in var.targets : idx => t }

  target_group_arn = var.target_group_arn
  target_id        = each.value.id
  port             = each.value.port
}
