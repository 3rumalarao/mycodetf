output "attachments" {
  description = "Map of the created target group attachment resources, keyed by index."
  value       = aws_lb_target_group_attachment.this
  # Note: This output provides the full resource details. Often, no output is needed from an attachment module.
  # Consider removing this output if it's not used by other parts of your configuration.
}
