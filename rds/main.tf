resource "aws_db_subnet_group" "this" {
  name       = lower("${var.rds_config.name}-subnet-group")
  # CORRECTED Typo: Use var.private_subnets
  subnet_ids = var.private_subnets
  tags       = merge(var.common_tags, {
     Name = lower("${var.rds_config.name}-subnet-group")
     # Add Environment tag for consistency if desired
     # Environment = var.environment
  })
}

resource "aws_db_instance" "this" {
  identifier            = lower("db-${var.rds_config.name}")
  engine                = var.rds_config.engine
  engine_version        = var.rds_config.engine_version # Use optional engine version
  instance_class        = var.rds_config.instance_class
  allocated_storage     = var.rds_config.storage
  username              = var.db_username
  password              = var.db_password # WARNING: Ensure this value is sourced securely!
  db_subnet_group_name  = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.rds_security_groups # Expects resolved IDs

  # --- Added Configurations ---
  multi_az                = var.multi_az
  storage_encrypted       = var.storage_encrypted
  kms_key_id              = var.storage_encrypted ? var.kms_key_id : null
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_retention_period > 0 ? var.backup_window : null # Only set if backups enabled
  maintenance_window      = var.maintenance_window
  skip_final_snapshot     = var.skip_final_snapshot # Now configurable
  deletion_protection     = var.deletion_protection # Now configurable
  parameter_group_name    = var.parameter_group_name
  option_group_name       = var.option_group_name
  publicly_accessible     = var.publicly_accessible

  # Add performance_insights_enabled, iam_database_authentication_enabled etc. if needed

  tags = merge(var.common_tags, {
    Name        = lower("db-${var.rds_config.name}")
    Environment = var.environment # Added Environment tag
  })

  # Explicit dependency on subnet group
  depends_on = [aws_db_subnet_group.this]
}
