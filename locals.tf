locals {
  # --- Process Server Definitions to Resolve SG IDs ---
  private_servers_processed = {
    for key, inst_config in var.private_servers : key => merge(inst_config, {
      # Expects EC2 module input 'security_group_ids'
      security_group_ids = [
        for sg_key in inst_config.security_groups :
        lookup(module.sg.sg_ids, lookup(var.instance_to_sg, key, sg_key), null)
      ]
    }) if inst_config != null
  }

  public_servers_processed = {
    for key, inst_config in var.public_servers : key => merge(inst_config, {
      # Expects EC2 module input 'security_group_ids'
      security_group_ids = [
        for sg_key in inst_config.security_groups :
        lookup(module.sg.sg_ids, lookup(var.instance_to_sg, key, sg_key), null)
      ]
    }) if inst_config != null
  }

  application_servers_processed = {
    for app_key, app_config in var.application_servers : app_key => {
      # --- Process Instances ---
      instances = {
        for inst_key, inst_config in lookup(app_config, "instances", {}) : inst_key => merge(inst_config, {
          # Expects EC2 module input 'security_group_ids'
          security_group_ids = [
            for sg_key in inst_config.security_groups :
            lookup(module.sg.sg_ids, lookup(var.instance_to_sg, inst_key, sg_key), null)
          ]
        }) if inst_config != null
      }
      # --- Process Load Balancer ---
      lb = merge(lookup(app_config, "lb", {}), {
         # Expects LB module input 'security_group_ids' within lb_config object
         security_group_ids = lookup(app_config, "lb", null) != null && app_config.lb.type == "application" ? [
           # Use the CORRECT standardized keys from .tfvars
           for sg_key in app_config.lb.security_groups : lookup(module.sg.sg_ids, sg_key, null)
         ] : [] # Empty list if no LB defined or if it's an NLB
      })
    } if app_config != null
  }

  # --- Dynamic Values for SSM/Outputs ---
  dynamic_infra_values = {
    "db_mysql_ip"        = try(module.private_ec2.private_ips["mysql"], null)
    "db_postgres_ip"     = try(module.private_ec2.private_ips["postgresql"], null)
    "rds_endpoint"       = try(module.rds.rds_endpoint, null)
    # Reference LB DNS from the for_each module map
    "crm_lb_dns"         = try(module.app_lb["crm"].lb_dns, null)
    "clover_lb_dns"      = try(module.app_lb["clover"].lb_dns, null)
    "ldaphaproxy_lb_dns" = try(module.app_lb["ldaphaproxy"].lb_dns, null)
    # Reference specific instance IPs from the for_each module map
    "crm_instance_1_ip"  = try(module.app_ec2["crm"].private_ips["crm1"], null)
    "crm_instance_2_ip"  = try(module.app_ec2["crm"].private_ips["crm2"], null)
    # Add others as needed
  }

  # --- Processed SSM Parameters ---
  # Construct the map expected by the SSM module
  ssm_parameters_processed = {
    for k, p in var.ssm_parameters : k => merge(p, {
      # Construct the full parameter name
      name  = "/${var.env}/${var.orgname}/${replace(k, "_", "/")}"
      # Lookup the dynamic value, provide default if not found
      value = lookup(local.dynamic_infra_values, k, "VALUE_NOT_FOUND")
      # Ensure value is string for SSM API
      value_string = p.type == "StringList" ? join(",", lookup(local.dynamic_infra_values, k, [])) : tostring(lookup(local.dynamic_infra_values, k, "VALUE_NOT_FOUND"))
      # Include optional key_id if present in var.ssm_parameters definition 'p'
      key_id = lookup(p, "key_id", null)
    }) # Includes all defined params, using default value if dynamic lookup fails
  }
}
