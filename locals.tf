

locals {
  # --- Process Server Definitions to Resolve SG IDs ---
  # This section assumes the EC2 module expects 'security_group_ids'
  private_servers_processed = {
    for key, inst_config in var.private_servers : key => merge(inst_config, {
      security_group_ids = [
        for sg_key in inst_config.security_groups :
        lookup(module.sg.sg_ids, lookup(var.instance_to_sg, key, sg_key), null)
      ]
    }) if inst_config != null
  }

  public_servers_processed = {
    for key, inst_config in var.public_servers : key => merge(inst_config, {
      security_group_ids = [
        for sg_key in inst_config.security_groups :
        lookup(module.sg.sg_ids, lookup(var.instance_to_sg, key, sg_key), null)
      ]
    }) if inst_config != null
  }

  # This processing step might be slightly different from the one in the separate locals.tf context,
  # ensure it correctly prepares data for the individual module calls in main.tf
  # Specifically, it prepares the 'security_group_ids' for EC2 instances.
  application_servers_processed = {
    for app_key, app_config in var.application_servers : app_key => {
      instances = {
        for inst_key, inst_config in lookup(app_config, "instances", {}) : inst_key => merge(inst_config, {
          security_group_ids = [
            for sg_key in inst_config.security_groups :
            lookup(module.sg.sg_ids, lookup(var.instance_to_sg, inst_key, sg_key), null)
          ]
        }) if inst_config != null
      }
      # LB processing is handled directly in main.tf for this version
      lb = lookup(app_config, "lb", {}) # Keep original lb config here
    } if app_config != null
  }


  # --- Dynamic Values for SSM/Outputs ---
  dynamic_infra_values = {
    "db_mysql_ip"        = try(module.private_ec2.private_ips["mysql"], null)
    "db_postgres_ip"     = try(module.private_ec2.private_ips["postgresql"], null)
    "rds_endpoint"       = try(module.rds.rds_endpoint, null)
    # CORRECTED: Reference individual module names from main.tf
    "crm_lb_dns"         = try(module.crm_lb.lb_dns, null)
    "clover_lb_dns"      = try(module.clover_lb.lb_dns, null)
    "ldaphaproxy_lb_dns" = try(module.ldaphaproxy_lb.lb_dns, null)
    # CORRECTED: Reference individual module names from main.tf
    "crm_instance_1_ip"  = try(module.crm_ec2.private_ips["crm1"], null)
    "crm_instance_2_ip"  = try(module.crm_ec2.private_ips["crm2"], null)
    # Add others as needed
    # "clover_instance_1_ip" = try(module.clover_ec2.private_ips["clover1"], null)
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
