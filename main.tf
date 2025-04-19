module "sg"         { source="./modules/sg"         security_groups=var.security_groups       vpc_id=var.vpc_id }
module "private_ec2"{ source="./modules/ec2"        instances=local.private_servers_override private_subnets=var.private_subnets public_subnets=var.public_subnets is_public=false env=var.env orgname=var.orgname common_tags=var.common_tags sg_dependency=module.sg }
module "public_ec2" { source="./modules/ec2"        instances=local.public_servers_override  private_subnets=var.private_subnets public_subnets=var.public_subnets is_public=true  env=var.env orgname=var.orgname common_tags=var.common_tags sg_dependency=module.sg }
module "crm_ec2"    { source="./modules/ec2"        instances=local.application_servers_override["crm"].instances private_subnets=var.private_subnets public_subnets=var.public_subnets is_public=false env=var.env orgname=var.orgname common_tags=var.common_tags sg_dependency=module.sg }
module "crm_lb"     { source="./modules/loadbalancer" lb=merge(var.application_servers.crm.lb,{security_groups=[module.sg.sg_ids["crm-lb-sg"]]}) subnet_ids=var.private_subnets vpc_id=var.vpc_id common_tags=var.common_tags }
module "crm_tga"    { source="./modules/tga"        target_group_arn=module.crm_lb.target_group_arn targets=[for id in values(module.crm_ec2.instance_ids):{id=id,port=80}] }
# ... similarly for clover_ec2, clover_lb, ldaphaproxy_ec2, ldaphaproxy_lb ...
module "rds"        { source="./modules/rds"        rds_config=var.rds_config privates_subnets=var.private_subnets environment=var.env db_username=var.db_username db_password=var.db_password common_tags=var.common_tags rds_security_groups=var.rds_security_groups }
module "efs"        { source="./modules/efs"        name=var.efs.name mount_targets=var.efs.mount_targets private_subnets=var.private_subnets environment=var.env vpc_id=var.vpc_id common_tags=var.common_tags security_groups=[module.sg.sg_ids["efs"]] }
module "ssm"       { source="./modules/ssm"       ssm_parameters=var.ssm_parameters }
module "backup"    { source="./modules/backup"    count=var.env=="prod"?1:0 backup_policy=var.backup_policy resource_arns=[] }
