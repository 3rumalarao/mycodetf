locals {
  private_subnet_map = { for idx, s in var.private_subnets : idx => s }
  public_subnet_map  = { for idx, s in var.public_subnets  : idx => s }

  private_servers_override = {
    for key, inst in var.private_servers :
    key => merge(inst, { security_groups = [ lookup(module.sg.sg_ids, lookup(var.instance_to_sg, key, key), null) ] })
  }
  public_servers_override = {
    for key, inst in var.public_servers :
    key => merge(inst, { security_groups = [ lookup(module.sg.sg_ids, lookup(var.instance_to_sg, key, key), null) ] })
  }
  application_servers_override = {
    for app_key, app in var.application_servers :
    app_key => merge(app, {
      instances = {
        for inst_key, inst in app.instances :
        inst_key => merge(inst, { security_groups = [ lookup(module.sg.sg_ids, lookup(var.instance_to_sg, inst_key, inst_key), null) ] })
      }
    })
  }

  computed_app_env = jsonencode({
    MYSQL_IP         = module.private_ec2.private_ips["mysql"],
    POSTGRES_IP      = module.private_ec2.private_ips["postgresql"],
    CRM_LB_DNS       = module.crm_lb.lb_dns,
    CLOVER_LB_DNS    = module.clover_lb.lb_dns,
    LDAPHAPROXY_NLB  = module.ldaphaproxy_lb.lb_dns
  })
}
