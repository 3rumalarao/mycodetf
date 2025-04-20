locals {
  # Determine default protocols if not specified
  tg_protocol       = coalesce(var.lb_config.health_check.protocol, var.lb_config.type == "application" ? "HTTP" : "TCP")
  listener_protocol = coalesce(var.lb_config.listener_protocol, var.lb_config.type == "application" ? (var.lb_config.certificate_arn != null ? "HTTPS" : "HTTP") : "TCP") # Default to HTTPS if cert provided for ALB
}

resource "aws_lb" "this" {
  name               = var.lb_config.name
  internal           = var.lb_config.scheme == "internal"
  load_balancer_type = var.lb_config.type

  # Assign Security Groups ONLY if it's an Application Load Balancer
  security_groups = var.lb_config.type == "application" ? var.lb_config.security_group_ids : null

  subnets = var.subnet_ids

  # Optional LB Attributes
  enable_deletion_protection = var.lb_config.enable_deletion_protection
  idle_timeout               = var.lb_config.idle_timeout
  # Add access_logs block if configured via variable

  tags = merge(var.common_tags, { Name = var.lb_config.name })
}

resource "aws_lb_target_group" "this" {
  name     = lower("${var.lb_config.name}-tg")
  port     = var.lb_config.listener_port
  protocol = local.tg_protocol
  vpc_id   = var.vpc_id

  target_type = var.lb_config.target_type

  deregistration_delay = var.lb_config.deregistration_delay
  # Add stickiness block if needed

  # --- CRITICAL: Added Health Check ---
  health_check {
    enabled             = lookup(var.lb_config.health_check, "enabled", true)
    interval            = lookup(var.lb_config.health_check, "interval", 30)
    # Path is only required for HTTP/HTTPS, provide default only then
    path                = contains(["HTTP", "HTTPS"], local.tg_protocol) ? lookup(var.lb_config.health_check, "path", "/") : null
    port                = lookup(var.lb_config.health_check, "port", "traffic-port")
    protocol            = local.tg_protocol # Use determined protocol
    timeout             = lookup(var.lb_config.health_check, "timeout", 5)
    healthy_threshold   = lookup(var.lb_config.health_check, "healthy_threshold", 3)
    unhealthy_threshold = lookup(var.lb_config.health_check, "unhealthy_threshold", 3)
    # Matcher is only valid for HTTP/HTTPS
    matcher             = contains(["HTTP", "HTTPS"], local.tg_protocol) ? lookup(var.lb_config.health_check, "matcher", "200") : null
  }

  tags = merge(var.common_tags, { Name = lower("${var.lb_config.name}-tg") })
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.lb_config.listener_port
  protocol          = local.listener_protocol

  # Optional: SSL/TLS configuration
  certificate_arn   = local.listener_protocol == "HTTPS" || local.listener_protocol == "TLS" ? var.lb_config.certificate_arn : null
  ssl_policy        = local.listener_protocol == "HTTPS" || local.listener_protocol == "TLS" ? var.lb_config.ssl_policy : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  # Listeners cannot be tagged directly in the resource block
  # Use aws_lb_listener_tag or aws_resourcegroups_group for tagging if needed
}
