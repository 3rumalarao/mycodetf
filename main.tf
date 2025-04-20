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
module "ssm" {
  source = "./ssm" # Verify path

  # Pass the definitions directly from variables.tfvars
  # Assumes ssm module input is 'ssm_parameters' and can handle the structure
  # defined in the root variables.tf (without pre-resolved 'name' or 'value')
  ssm_parameters = var.ssm_parameters

  common_tags = var.common_tags # Pass common tags

  # No explicit depends_on needed unless module needs specific resource ARNs not passed in vars
}

# --- Backup ---
module "backup" {
  source = "./backup" # Verify path
  count  = var.env == "prod" ? 1 : 0 # Correct conditional creation

  backup_policy = var.backup_policy # Pass policy object
  common_tags   = var.common_tags
  # Assumes backup module uses tag-based selection internally
}
