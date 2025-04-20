resource "aws_instance" "this" {
  for_each = var.instances

  ami           = each.value.ami
  instance_type = each.value.instance_type
  key_name      = each.value.key_name

  # Subnet Selection (using index - acknowledge limitations regarding AZ)
  # Consider enhancing this logic later if AZ-specific placement is critical and index isn't reliable.
  subnet_id = var.is_public ? var.public_subnets[each.value.subnet_index] : var.private_subnets[each.value.subnet_index]

  # Use the resolved Security Group IDs passed via the input variable
  vpc_security_group_ids = each.value.security_group_ids # CHANGED from each.value.security_groups

  # Network interface configuration (Example: if you need EIP for public instances)
  # Note: 'associate_public_ip_address' in the main instance block is for default VPCs.
  # For custom VPCs, manage EIPs separately or configure the primary network interface.
  # This example assumes EIP is handled elsewhere or via network_interface block if needed.
  # associate_public_ip_address = var.is_public # Only works in default VPC

  # Add other instance configurations as needed (user_data, ebs_block_device, etc.)
  # user_data = each.value.user_data # If user_data is added to the variable

  tags = merge(
    var.common_tags,
    {
      # Using lower() ensures consistent tag casing
      Name           = lower("${var.env}-${var.orgname}-${each.key}")
      OWResourceName = lower("${var.env}-${var.orgname}-${each.key}") # Assuming this matches Name tag intent
      # Add other instance-specific tags if needed
    }
  )

  # REMOVED: depends_on = [var.sg_dependency] - Implicit dependency is sufficient.
}

# Optional: Manage Elastic IPs for public instances explicitly
# resource "aws_eip" "this" {
#   for_each = { for k, v in var.instances : k => v if var.is_public && lookup(v, "allocate_eip", false) }
#   instance = aws_instance.this[each.key].id
#   vpc      = true
#   tags     = merge(var.common_tags, { Name = lower("${var.env}-${var.orgname}-${each.key}-eip") })
# }
