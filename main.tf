
# REMOVED: The large locals { ... } block previously here.
# This file now relies on the separate locals.tf file.

# --- Security Groups ---
module "sg" {
  source = "./sg" # Verify path

  security_groups = var.security_groups
  vpc_id          = var.vpc_id
  common_tags     = var.common_tags # Pass common tags
}

# --- EC2 Instances ---
module "private_ec2" {
  source = "./ec2" # Verify path

  # Use override local from separate locals.tf
  # Assumes locals.tf correctly resolves SG keys to IDs under the 'security_groups' key
  instances       = local.private_servers_processed
  private_subnets = var.private_subnets
  public_subnets  = [] # Private instances don't need public subnets list
  is_public       = false
  env             = var.env
  orgname         = var.orgname
  common_tags     = var.common_tags
  # REMOVED: sg_dependency
}

module "public_ec2" {
  source = "./ec2" # Verify path

  # Use override local from separate locals.tf
  instances       = local.public_servers_processed
  private_subnets = [] # Public instances don't need private subnets list
  public_subnets  = var.public_subnets
  is_public       = true # CORRECTED
  env             = var.env
  orgname         = var.orgname
  common_tags     = var.common_tags
  # REMOVED: sg_dependency
}

# --- Application Tiers (Individual Modules - Reverted from for_each) ---
module "crm_ec2" {
  source = "./ec2" # Verify path

  # Use override local from separate locals.tf
  instances       = local.application_servers_processed["crm"].instances
  private_subnets = var.private_subnets
  public_subnets  = []
  is_public       = false
  env             = var.env
  orgname         = var.orgname
  common_tags     = merge(var.common_tags, { Application = "crm" })
  # REMOVED: sg_dependency
}

module "crm_lb" {
  source = "./loadbalancer" # Verify path

  # Pass lb_config object to the module
  lb_config = merge(var.application_servers.crm.lb, {
      # Resolve SG ID using CORRECT standardized key
      security_group_ids = [lookup(module.sg.sg_ids, "crm-lb-sg", null)]
  })
  subnet_ids  = var.private_subnets # Use private subnets for internal LBs
  vpc_id      = var.vpc_id
  common_tags = merge(var.common_tags, { Application = "crm" })
  depends_on  = [module.sg]
}

module "crm_tga" {
  source = "./tga" # Verify path

  target_group_arn = module.crm_lb.target_group_arn
  targets = [
    for id in values(module.crm_ec2.instance_ids) : {
      id   = id
      # Reference port from variable definition
      port = var.application_servers.crm.lb.listener_port
  }]
  depends_on = [module.crm_ec2, module.crm_lb]
}

module "clover_ec2" {
  source = "./ec2" # Verify path

  instances       = local.application_servers_processed["clover"].instances
  private_subnets = var.private_subnets
  public_subnets  = []
  is_public       = false
  env             = var.env
  orgname         = var.orgname
  common_tags     = merge(var.common_tags, { Application = "clover" })
  # REMOVED: sg_dependency
}

module "clover_lb" {
  source = "./loadbalancer" # Verify path

  lb_config = merge(var.application_servers.clover.lb, {
      # Resolve SG ID using CORRECT standardized key
      security_group_ids = [lookup(module.sg.sg_ids, "clover-lb-sg", null)]
  })
  subnet_ids  = var.private_subnets
  vpc_id      = var.vpc_id
  common_tags = merge(var.common_tags, { Application = "clover" })
  depends_on  = [module.sg]
}

module "clover_tga" {
  source = "./tga" # Verify path

  target_group_arn = module.clover_lb.target_group_arn
  targets = [
    for id in values(module.clover_ec2.instance_ids) : {
      id   = id
      port = var.application_servers.clover.lb.listener_port
  }]
  depends_on = [module.clover_ec2, module.clover_lb]
}

module "ldaphaproxy_ec2" {
  source = "./ec2" # Verify path

  instances       = local.application_servers_processed["ldaphaproxy"].instances
  private_subnets = var.private_subnets
  public_subnets  = []
  is_public       = false
  env             = var.env
  orgname         = var.orgname
  common_tags     = merge(var.common_tags, { Application = "ldaphaproxy" })
  # REMOVED: sg_dependency
}

module "ldaphaproxy_lb" {
  source = "./loadbalancer" # Verify path

  # NLBs don't use security_groups directly, so no merge needed for that
  lb_config   = var.application_servers.ldaphaproxy.lb
  subnet_ids  = var.private_subnets
  vpc_id      = var.vpc_id
  common_tags = merge(var.common_tags, { Application = "ldaphaproxy" })
  # No depends_on needed for SG as NLB doesn't use it
}

module "ldaphaproxy_tga" {
  source = "./tga" # Verify path

  target_group_arn = module.ldaphaproxy_lb.target_group_arn
  targets = [
    for id in values(module.ldaphaproxy_ec2.instance_ids) : {
      id   = id
      port = var.application_servers.ldaphaproxy.lb.listener_port
  }]
  depends_on = [module.ldaphaproxy_ec2, module.ldaphaproxy_lb]
}

# --- Database ---
module "rds" {
  source = "./rds" # Verify path

  rds_config      = var.rds_config
  private_subnets = var.private_subnets # CORRECTED typo
  environment     = var.env
  db_username     = var.db_username
  # WARNING: Securely source db_password (e.g., from Secrets Manager data source or TF_VAR env var)
  db_password     = var.db_password
  common_tags     = var.common_tags
  # Resolve SG ID using CORRECT standardized key
  rds_security_groups = [lookup(module.sg.sg_ids, "rds-access-sg", null)]
  depends_on      = [module.sg]
}

# --- Shared Storage ---
module "efs" {
  source = "./efs" # Verify path

  name            = var.efs.name
  mount_targets   = var.efs.mount_targets
  vpc_id          = var.vpc_id
  private_subnets = var.private_subnets
  environment     = var.env
  common_tags     = var.common_tags
  # Resolve SG ID using CORRECT standardized key
  security_groups = [lookup(module.sg.sg_ids, "efs-sg", null)]
  depends_on      = [module.sg]
}

# --- SSM Parameters ---
# Reverted to simpler approach - passes definitions from tfvars directly.
# Dynamic values (IPs, DNS) are NOT injected here.
# Consider using data sources within application configuration/userdata to read SSM,
# or enhance the SSM module/locals if dynamic injection is strictly needed via Terraform.
# --- SSM Parameters ---
module "ssm" {
  source = "./ssm" # Verify path

  # CORRECTED: Pass the processed map from locals.tf
  # This map contains the generated 'name' and the string-formatted 'value'
  # Assumes the SSM module's input variable is named 'ssm_parameters'
  ssm_parameters = {
     for k, p in local.ssm_parameters_processed : k => {
        # Map attributes from the processed local to the module's expected input object
        name        = p.name
        description = p.description
        value       = p.value_string # Use the correctly formatted string value
        type        = p.type
        key_id      = p.key_id
     }
  }

  common_tags = var.common_tags # Pass common tags

  # Add depends_on because local.ssm_parameters_processed uses local.dynamic_infra_values,
  # which in turn depends on other modules.
  depends_on = [
    module.private_ec2,
    module.rds,
    module.crm_lb,
    module.clover_lb,
    module.ldaphaproxy_lb,
    module.crm_ec2 # Added missing dependency from dynamic_infra_values
    # Add other modules if their outputs are used in dynamic_infra_values
  ]
}


# --- Backup ---
module "backup" {
  source = "./backup" # Verify path
  count  = var.env == "prod" ? 1 : 0 # Correct conditional creation

  backup_policy = var.backup_policy # Pass policy object
  common_tags   = var.common_tags
  # Assumes backup module uses tag-based selection internally
}


# --- Scheduler Infrastructure ---
# (SNS Topic, Subscription, IAM Module, Lambda Function, EventBridge Rules/Targets, Log Group)
# Use the code blocks provided in the previous correct "full implementation" answer for these resources.
# They rely on local.resource_prefix, local.lambda_function_name, var.schedule_*, var.notification_email etc.
# --- Data Sources ---
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# --- SNS Notification Setup ---
resource "aws_sns_topic" "scheduler_notifications" {
  name = "${local.resource_prefix}-scheduler-notifications"
  tags = merge(var.common_tags, { Name = "${local.resource_prefix}-scheduler-notifications" })
}

resource "aws_sns_topic_subscription" "email_subscription" {
  count = var.notification_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.scheduler_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# --- IAM Module Instance ---
module "scheduler_iam" {
  source = "./modules/iam_scheduler" # Corrected path
  role_name_prefix     = local.resource_prefix
  sns_topic_arn        = aws_sns_topic.scheduler_notifications.arn
  lambda_function_name = local.lambda_function_name
  tags                 = var.common_tags
}

# --- Lambda Function ---
data "archive_file" "lambda_scheduler_notify_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/lambda_scheduler_notify.zip"
}

resource "aws_lambda_function" "scheduler_notify" {
  filename         = data.archive_file.lambda_scheduler_notify_zip.output_path
  function_name    = local.lambda_function_name
  role             = module.scheduler_iam.lambda_role_arn
  handler          = "scheduler_notify.lambda_handler"
  source_code_hash = data.archive_file.lambda_scheduler_notify_zip.output_base64sha256
  runtime          = "python3.9"
  timeout          = var.lambda_timeout_seconds
  environment {
    variables = {
      REGION        = data.aws_region.current.name
      TAG_KEY       = var.schedule_tag_key
      TAG_VALUE     = var.schedule_tag_value
      SNS_TOPIC_ARN = aws_sns_topic.scheduler_notifications.arn
    }
  }
  tags = merge(var.common_tags, { Name = local.lambda_function_name })
  depends_on = [
    module.scheduler_iam,
    aws_cloudwatch_log_group.lambda_scheduler_notify_lg
  ]
}

# --- EventBridge Rules & Targets ---
resource "aws_cloudwatch_event_rule" "stop_resources" {
  name                = "${local.resource_prefix}-stop-resources-rule"
  description         = "Stops tagged EC2/RDS resources via Lambda"
  schedule_expression = var.schedule_stop_cron
  tags                = merge(var.common_tags, { Name = "${local.resource_prefix}-stop-resources-rule" })
  timezone            = var.schedule_timezone != "" ? var.schedule_timezone : null
}

resource "aws_cloudwatch_event_rule" "start_resources" {
  name                = "${local.resource_prefix}-start-resources-rule"
  description         = "Starts tagged EC2/RDS resources via Lambda"
  schedule_expression = var.schedule_start_cron
  tags                = merge(var.common_tags, { Name = "${local.resource_prefix}-start-resources-rule" })
  timezone            = var.schedule_timezone != "" ? var.schedule_timezone : null
}

resource "aws_lambda_permission" "allow_stop_event" {
  statement_id  = "AllowExecutionFromCloudWatchStopRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scheduler_notify.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_resources.arn
}

resource "aws_lambda_permission" "allow_start_event" {
  statement_id  = "AllowExecutionFromCloudWatchStartRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scheduler_notify.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_resources.arn
}

resource "aws_cloudwatch_event_target" "stop_target" {
  rule      = aws_cloudwatch_event_rule.stop_resources.name
  target_id = "${local.resource_prefix}-stop-lambda-target"
  arn       = aws_lambda_function.scheduler_notify.arn
  input     = jsonencode({"action" : "STOP"})
  depends_on = [aws_lambda_permission.allow_stop_event]
}

resource "aws_cloudwatch_event_target" "start_target" {
  rule      = aws_cloudwatch_event_rule.start_resources.name
  target_id = "${local.resource_prefix}-start-lambda-target"
  arn       = aws_lambda_function.scheduler_notify.arn
  input     = jsonencode({"action" : "START"})
  depends_on = [aws_lambda_permission.allow_start_event]
}

# --- CloudWatch Log Group for Lambda ---
resource "aws_cloudwatch_log_group" "lambda_scheduler_notify_lg" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = var.log_retention_days
  tags              = merge(var.common_tags, { Name = "${local.lambda_function_name}-log-group" })
}
