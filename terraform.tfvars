aws_region = "us-east-1"
env        = "dev"
orgname    = "sap"
vpc_id     = "vpc-12345678"
private_subnets = ["subnet-aaa111","subnet-bbb222","subnet-ccc333"]
public_subnets  = ["subnet-ddd444","subnet-eee555","subnet-fff666"]
# Private servers
private_servers = {
  mysql      = { ami="ami-mysql",      instance_type="r5.4xlarge", subnet_index=1, key_name="private-instance", security_groups=["placeholder"] },
  postgresql = { ami="ami-postgres",   instance_type="r5.4xlarge", subnet_index=2, key_name="private-instance", security_groups=["placeholder"] }
}
# Application servers (CRM example only shown)
application_servers = {
  crm = {
    instances = {
      crm1 = { ami="ami-565732", instance_type="m5.xlarge", subnet_index=0, key_name="private-instance", az="us-east-1a", security_groups=["placeholder"] },
      crm2 = { ami="ami-565732", instance_type="m5.xlarge", subnet_index=1, key_name="private-instance", az="us-east-1b", security_groups=["placeholder"] }
    }
    lb = { name="dev-sap-crm-lb", type="application", scheme="internal", listener_port=80, security_groups=["crm-lb-sg"] }
  }
}
# SG definitions (keys must match instance_to_sg mapping)
security_groups = {
  mysql      = { name="dev-sap-mysql-sg",      description="MySQL SG",      ingress=[{from_port=3306,to_port=3306,protocol="tcp",cidr_blocks=["10.0.0.0/16"]}], egress=[{from_port=0,to_port=0,protocol="-1",cidr_blocks=["0.0.0.0/0"]}] },
  postgresql = { name="dev-sap-postgresql-sg", description="Postgres SG",   ingress=[{from_port=5432,to_port=5432,protocol="tcp",cidr_blocks=["10.0.0.0/16"]}], egress=[{from_port=0,to_port=0,protocol="-1",cidr_blocks=["0.0.0.0/0"]}] },
  "crm-sg"   = { name="dev-sap-crm-sg",        description="CRM SG",        ingress=[{from_port=80,to_port=80,protocol="tcp",cidr_blocks=["10.0.0.0/16"]}], egress=[{from_port=0,to_port=0,protocol="-1",cidr_blocks=["0.0.0.0/0"]}] },
  "crm-lb-sg"= { name="dev-sap-crm-lb-sg",     description="CRM LB SG",     ingress=[{from_port=80,to_port=80,protocol="tcp",cidr_blocks=["10.0.0.0/16"]}], egress=[{from_port=0,to_port=0,protocol="-1",cidr_blocks=["0.0.0.0/0"]}] }
}
