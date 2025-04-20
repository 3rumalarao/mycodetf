aws_region = "us-east-1"
env        = "dev"
orgname    = "sap"

# --- Networking (Provided by CCOE) ---
# ACTION: Replace placeholder VPC and Subnet IDs with actual values for the 'dev' environment.
vpc_id          = "vpc-12345678"
private_subnets = ["subnet-aaa111", "subnet-bbb222", "subnet-ccc333"]
public_subnets  = ["subnet-ddd444", "subnet-eee555", "subnet-fff666"]

# --- EC2 Instance Definitions ---
# ACTION: Replace all 'ami-*-placeholder' values with actual AMI IDs for 'us-east-1'.
# ACTION: Verify 'private-instance' and 'public-instance' key pairs exist in 'us-east-1'.
# NOTE: Subnet selection uses 'subnet_index'. Be aware this is sensitive to the order of subnets in the lists above.

private_servers = {
  mysql = {
    ami             = "ami-mysql-placeholder"
    instance_type   = "r5.4xlarge"
    subnet_index    = 1
    key_name        = "private-instance"
    security_groups = ["mysql-sg"] # Standardized key - OK
  },
  postgresql = {
    ami             = "ami-postgres-placeholder"
    instance_type   = "r5.xlarge"
    subnet_index    = 2
    key_name        = "private-instance"
    security_groups = ["postgresql-sg"] # Standardized key - OK
  },
  metrics = {
    ami             = "ami-metrics-placeholder"
    instance_type   = "m5.large"
    subnet_index    = 2
    key_name        = "private-instance"
    security_groups = ["metrics-sg"] # Standardized key - OK
  },
  ems = {
    ami             = "ami-ems-placeholder"
    instance_type   = "r5.xlarge"
    subnet_index    = 2
    key_name        = "private-instance"
    security_groups = ["ems-sg"] # Standardized key - OK
  },
  regui = {
    ami             = "ami-regui-placeholder"
    instance_type   = "r5.4xlarge"
    subnet_index    = 2
    key_name        = "private-instance"
    security_groups = ["regui-sg"] # Standardized key - OK
  },
  csmerge = {
    ami             = "ami-csmerge-placeholder"
    instance_type   = "m5.xlarge"
    subnet_index    = 2
    key_name        = "private-instance"
    security_groups = ["csmerge-sg"] # Standardized key - OK
  },
  merger = {
    ami             = "ami-merger-placeholder"
    instance_type   = "t3.xlarge"
    subnet_index    = 2
    key_name        = "private-instance"
    security_groups = ["merger-sg"] # Standardized key - OK
  }
}

public_servers = {
  regcom = {
    ami             = "ami-regcom-placeholder"
    instance_type   = "r5.4xlarge"
    subnet_index    = 1 # Index into public_subnets
    key_name        = "public-instance"
    allocate_eip    = true
    security_groups = ["regcom-sg"] # Standardized key - OK
  },
  ercot = {
    ami             = "ami-ercot-placeholder"
    instance_type   = "r5.4xlarge"
    subnet_index    = 2 # Index into public_subnets
    key_name        = "public-instance"
    allocate_eip    = true
    security_groups = ["ercot-sg"] # Standardized key - OK
  }
}

application_servers = {
  crm = {
    instances = {
      crm1 = {
        ami             = "ami-crm-placeholder"
        instance_type   = "m5.xlarge"
        subnet_index    = 0 # Index into private_subnets
        key_name        = "private-instance"
        az              = "us-east-1a"
        security_groups = ["crm-sg"] # Standardized key - OK
      },
      crm2 = {
        ami             = "ami-crm-placeholder"
        instance_type   = "m5.xlarge"
        subnet_index    = 1 # Index into private_subnets
        key_name        = "private-instance"
        az              = "us-east-1b"
        security_groups = ["crm-sg"] # Standardized key - OK
      }
    },
    lb = {
      name            = "dev-sap-crm-lb"
      type            = "application"
      scheme          = "internal"
      listener_port   = 80
      security_groups = ["crm-lb-sg"] # Standardized key - OK
      # ADDED: Example Health Check configuration (adjust path etc. as needed)
      health_check = {
        path                = "/" # ACTION: Verify/Update health check path
        interval            = 30
        timeout             = 5
        healthy_threshold   = 3
        unhealthy_threshold = 3
        matcher             = "200"
      }
    }
  },
  clover = {
    instances = {
      clover1 = {
        ami             = "ami-clover-placeholder"
        instance_type   = "m5.xlarge"
        subnet_index    = 0 # Index into private_subnets
        key_name        = "private-instance"
        az              = "us-east-1a"
        security_groups = ["clover-sg"] # Standardized key - OK
      },
      clover2 = {
        ami             = "ami-clover-placeholder"
        instance_type   = "m5.xlarge"
        subnet_index    = 1 # Index into private_subnets
        key_name        = "private-instance"
        az              = "us-east-1b"
        security_groups = ["clover-sg"] # Standardized key - OK
      }
    },
    lb = {
      name            = "dev-sap-clover-lb"
      type            = "application"
      scheme          = "internal"
      listener_port   = 8080
      security_groups = ["clover-lb-sg"] # Standardized key - OK
      # ADDED: Example Health Check configuration (adjust path etc. as needed)
      health_check = {
        path                = "/health" # ACTION: Verify/Update health check path
        interval            = 30
        timeout             = 5
        healthy_threshold   = 3
        unhealthy_threshold = 3
        matcher             = "200"
      }
    }
  },
  ldaphaproxy = {
    instances = {
      ldaphaproxy1 = {
        ami             = "ami-ldaphaproxy-placeholder"
        instance_type   = "m5.xlarge"
        subnet_index    = 0 # Index into private_subnets
        key_name        = "private-instance"
        az              = "us-east-1a"
        security_groups = ["ldaphaproxy-sg"] # Standardized key - OK
      },
      ldaphaproxy2 = {
        ami             = "ami-ldaphaproxy-placeholder"
        instance_type   = "m5.xlarge"
        subnet_index    = 1 # Index into private_subnets
        key_name        = "private-instance"
        az              = "us-east-1b"
        security_groups = ["ldaphaproxy-sg"] # Standardized key - OK
      }
    },
    lb = {
      name            = "dev-sap-ldaphaproxy-lb"
      type            = "network" # NLB
      scheme          = "internal"
      listener_port   = 389
      # security_groups omitted correctly for NLB
      # ADDED: Example Health Check configuration (NLB uses TCP/HTTP/HTTPS checks)
      health_check = {
        protocol            = "TCP" # Or HTTP/HTTPS if applicable on a different port
        interval            = 30
        healthy_threshold   = 3
        unhealthy_threshold = 3
        # path, matcher, timeout are not used for TCP checks
      }
    }
  }
}

# --- EFS Definition ---
efs = {
  name = "dev-sap-efs"
  mount_targets = [
    { az = "us-east-1a", subnet_index = 0 },
    { az = "us-east-1b", subnet_index = 1 },
    { az = "us-east-1c", subnet_index = 2 }
  ]
}

# --- RDS Definition ---
rds_config = {
  name           = "dev-sap-rds-db"
  instance_class = "db.t3.medium"
  engine         = "mysql"
  storage        = 100
  # ACTION: Add optional RDS configurations if needed (e.g., engine_version, multi_az=false)
  # engine_version = "8.0.28"
  # multi_az       = false
}

db_username = "admin"
# ACTION: CRITICAL - Replace placeholder with a secure method (Secrets Manager data source or TF_VAR env var).
db_password = "dev-db-password-needs-changing"

rds_security_groups = ["rds-access-sg"] # Standardized key - OK

# --- Security Group Definitions ---
# ACTION: Review and fill in ALL 'TODO' items below (source keys, CIDRs, specific ingress rules).
security_groups = {

  # --- Instance SGs ---
  "mysql-sg" = {
    name        = "dev-sap-mysql-sg"
    description = "Allow MySQL traffic from specific app tiers"
    ingress     = [{ description = "Allow MySQL from CRM instances", from_port = 3306, to_port = 3306, protocol = "tcp", security_group_keys = ["crm-sg"] }] # ACTION: Verify sources
    egress      = [{ description = "Allow all outbound", from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  },
  "postgresql-sg" = {
    name        = "dev-sap-postgresql-sg"
    description = "Allow PostgreSQL traffic from specific app tiers"
    ingress     = [{ description = "Allow PostgreSQL from ???", from_port = 5432, to_port = 5432, protocol = "tcp", security_group_keys = [] }] # TODO: Add source SG keys (e.g., "clover-sg"?)
    egress      = [{ description = "Allow all outbound", from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  },
  "metrics-sg" = {
    name        = "dev-sap-metrics-sg"
    description = "SG for Metrics instances"
    ingress     = [] # TODO: Define specific ingress rules (e.g., port 9090 from monitoring tools/LBs?)
    egress      = [{ description = "Allow all outbound", from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  },
  "ems-sg" = {
    name        = "dev-sap-ems-sg"
    description = "SG for EMS instances"
    ingress     = [] # TODO: Define specific ingress rules
    egress      = [{ description = "Allow all outbound", from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  },
  "regui-sg" = {
    name        = "dev-sap-regui-sg"
    description = "SG for REGUI instances"
    ingress     = [] # TODO: Define specific ingress rules
    egress      = [{ description = "Allow all outbound", from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  },
  "csmerge-sg" = {
    name        = "dev-sap-csmerge-sg"
    description = "SG for CSMerge instances"
    ingress     = [] # TODO: Define specific ingress rules
    egress      = [{ description = "Allow all outbound", from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  },
  "merger-sg" = {
    name        = "dev-sap-merger-sg"
    description = "SG for Merger instances"
    ingress     = [] # TODO: Define specific ingress rules
    egress      = [{ description = "Allow all outbound", from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  },
  "regcom-sg" = {
    name        = "dev-sap-regcom-sg"
    description = "SG for REGCOM public instances"
    ingress     = [
        { description = "Allow SSH from trusted IPs", from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["YOUR_TRUSTED_IP/32"] } # TODO: Replace CIDR
        # TODO: Add other rules (e.g., HTTPS?)
    ]
    egress      = [{ description = "Allow all outbound", from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  },
  "ercot-sg" = {
    name        = "dev-sap-ercot-sg"
    description = "SG for ERCOT public instances"
    ingress     = [
        { description = "Allow SSH from trusted IPs", from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["YOUR_TRUSTED_IP/32"] } # TODO: Replace CIDR
        # TODO: Add other rules?
    ]
    egress      = [{ description = "Allow all outbound", from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  },

  # --- Application Tier SGs ---
  "crm-sg" = {
    name        = "dev-sap-crm-sg"
    description = "Allow traffic to CRM instances only from CRM LB"
    ingress     = [{ description = "Allow HTTP from CRM LB", from_port = 80, to_port = 80, protocol = "tcp", security_group_keys = ["crm-lb-sg"] }] # OK
    egress      = [{ description = "Allow all outbound", from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  },
  "clover-sg" = {
    name        = "dev-sap-clover-sg"
    description = "Allow traffic to Clover instances only from Clover LB"
    ingress     = [{ description = "Allow App traffic from Clover LB", from_port = 8080, to_port = 8080, protocol = "tcp", security_group_keys = ["clover-lb-sg"] }] # OK
    egress      = [{ description = "Allow all outbound", from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  },
  "ldaphaproxy-sg" = {
    name        = "dev-sap-ldaphaproxy-sg"
    description = "Allow LDAP traffic to LDAP/HAProxy instances from clients/NLB"
    ingress     = [{ description = "Allow LDAP from internal clients", from_port = 389, to_port = 389, protocol = "tcp", cidr_blocks = ["10.0.0.0/8"] }] # TODO: Refine CIDR or use specific source SGs
    egress      = [{ description = "Allow all outbound", from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  },

  # --- Load Balancer SGs (Only for ALBs) ---
  "crm-lb-sg" = {
    name        = "dev-sap-crm-lb-sg"
    description = "Allow HTTP traffic to CRM ALB from internal clients"
    ingress     = [{ description = "Allow HTTP from internal clients", from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["10.0.0.0/8"] }] # TODO: Refine CIDR or use specific source SGs
    egress      = [{ description = "Allow all outbound", from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  },
  "clover-lb-sg" = {
    name        = "dev-sap-clover-lb-sg"
    description = "Allow App traffic to Clover ALB from internal clients"
    ingress     = [{ description = "Allow App traffic from internal clients", from_port = 8080, to_port = 8080, protocol = "tcp", cidr_blocks = ["10.0.0.0/8"] }] # TODO: Refine CIDR or use specific source SGs
    egress      = [{ description = "Allow all outbound", from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  },

  # --- Service SGs ---
  "efs-sg" = {
    name        = "dev-sap-efs-sg"
    description = "Allow NFS traffic to EFS from specific EC2 instances"
    ingress     = [{ description = "Allow NFS from App/Data tiers", from_port = 2049, to_port = 2049, protocol = "tcp", security_group_keys = ["crm-sg", "clover-sg", "mysql-sg" /* add others */ ] }] # TODO: List ALL SG keys that need EFS access
    egress      = [{ description = "Allow all outbound", from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  },
  "rds-access-sg" = {
    name        = "dev-sap-rds-access-sg"
    description = "Allow DB traffic to RDS from specific EC2 instances"
    ingress     = [
        { description = "Allow MySQL/Postgres from App/Data tiers", from_port = 3306, to_port = 3306, protocol = "tcp", security_group_keys = ["crm-sg", "mysql-sg" /* add others */ ] }, # TODO: List ALL SG keys that need RDS access on port 3306
        # { description = "Allow Postgres from App/Data tiers", from_port = 5432, to_port = 5432, protocol = "tcp", security_group_keys = ["clover-sg", "postgresql-sg" /* add others */ ] } # TODO: Uncomment & list ALL SG keys if using Postgres
    ]
    egress      = [{ description = "Allow all outbound", from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
  }
}

# --- Common Tags ---
# ACTION: Consider making OWEnvironment/OWRegion dynamic using var.env/var.aws_region in main.tf/locals.tf if desired.
common_tags = {
  OWEnvironment       = "DEV"
  OWCompanyCode       = "5647"
  OWCostCenter        = "23784304"
  OWResourceName      = "AWS" # Consider making more specific
  OWBusinessApplication = "Demand-Response"
  OWRegion            = "us-east-1"
  Terraform           = "true"
}

# --- Backup Policy ---
# Values here are appropriate for 'dev' (where backup module won't run)
backup_policy = {
  retention_days      = 7
  resource_tag_filter = "dev-backup"
  resource_tag_key    = "Backup"
  schedule            = "cron(0 5 * * ? *)"
}

# --- SSM Parameters ---
# Defines parameters to create; values populated dynamically by main.tf/locals.tf
ssm_parameters = {
  "db_mysql_ip"    = { description = "Private IP of MySQL instance", type = "String" }
  "db_postgres_ip" = { description = "Private IP of PostgreSQL instance", type = "String" }
  "rds_endpoint"   = { description = "RDS Database Endpoint", type = "String" }
  "crm_lb_dns"     = { description = "DNS Name for CRM Load Balancer", type = "String" }
  "clover_lb_dns"  = { description = "DNS Name for Clover Load Balancer", type = "String" }
  # Add other keys corresponding to values in locals.tf/dynamic_infra_values if needed
}

