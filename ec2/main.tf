resource "aws_instance" "this" {
  for_each = var.instances

  ami           = each.value.ami
  instance_type = each.value.instance_type
  key_name      = each.value.key_name
  subnet_id     = var.is_public ? var.public_subnets[each.value.subnet_index] : var.private_subnets[each.value.subnet_index]

  vpc_security_group_ids = each.value.security_groups

  tags = merge(
    var.common_tags,
    {
      Name = lower("${var.env}-${var.orgname}-${each.key}"),
      OWResourceName = lower("${var.env}-${var.orgname}-${each.key}")
    }
  )

  depends_on = [var.sg_dependency]
}
