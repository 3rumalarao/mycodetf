resource "aws_db_subnet_group" "this" {
  name       = lower("${var.rds_config.name}-subnet-group")
  subnet_ids = var.privates_subnets
  tags       = merge(var.common_tags, { Name = "${var.rds_config.name}-subnet-group" })
}

resource "aws_db_instance" "this" {
  identifier            = lower("db-${var.rds_config.name}")
  engine                = var.rds_config.engine
  instance_class        = var.rds_config.instance_class
  allocated_storage     = var.rds_config.storage
  username              = var.db_username
  password              = var.db_password
  db_subnet_group_name  = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.rds_security_groups
  skip_final_snapshot   = true

  tags = merge(var.common_tags, { Name = lower("db-${var.rds_config.name}") })
}
