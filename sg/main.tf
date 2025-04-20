# REMOVED: random_id resource - Use predictable names

resource "aws_security_group" "this" {
  for_each = var.security_groups

  # Use the name directly from the input variable
  name        = each.value.name
  description = each.value.description
  vpc_id      = var.vpc_id

  # --- Ingress Rules ---
  dynamic "ingress" {
    # Iterate through the list of ingress rule definitions for the current SG
    for_each = each.value.ingress

    # Content block defines the arguments for the aws_security_group ingress block
    content {
      # Required arguments
      from_port = ingress.value.from_port
      to_port   = ingress.value.to_port
      protocol  = ingress.value.protocol

      # Optional arguments - Terraform handles null values correctly by omitting the argument
      description       = lookup(ingress.value, "description", null)
      cidr_blocks       = lookup(ingress.value, "cidr_blocks", null)
      ipv6_cidr_blocks  = lookup(ingress.value, "ipv6_cidr_blocks", null)
      prefix_list_ids   = lookup(ingress.value, "prefix_list_ids", null)
      # Pass the source SG ID directly if provided
      security_groups   = lookup(ingress.value, "source_security_group_id", null) != null ? [ingress.value.source_security_group_id] : null
      self              = lookup(ingress.value, "self", null)
    }
  }

  # --- Egress Rules ---
  dynamic "egress" {
    # Iterate through the list of egress rule definitions for the current SG
    for_each = each.value.egress

    content {
      # Required arguments
      from_port = egress.value.from_port
      to_port   = egress.value.to_port
      protocol  = egress.value.protocol

      # Optional arguments
      description       = lookup(egress.value, "description", null)
      cidr_blocks       = lookup(egress.value, "cidr_blocks", null)
      ipv6_cidr_blocks  = lookup(egress.value, "ipv6_cidr_blocks", null)
      prefix_list_ids   = lookup(egress.value, "prefix_list_ids", null)
      # Use destination_security_group_id for the security_groups argument in egress
      security_groups   = lookup(egress.value, "destination_security_group_id", null) != null ? [egress.value.destination_security_group_id] : null
      self              = lookup(egress.value, "self", null) # Less common for egress
    }
  }

  # Apply common tags and the specific Name tag
  tags = merge(var.common_tags, {
    Name = each.value.name
  })
}
