resource "aws_rds_cluster" "main" {
  cluster_identifier = "${var.org}-${var.env}-rds-cluster"

  engine_mode    = "serverless"
  engine         = "aurora-postgresql"
  engine_version = "10.14"

  enable_http_endpoint = true

  scaling_configuration {
    auto_pause               = true
    max_capacity             = 64
    min_capacity             = 2
    seconds_until_auto_pause = 1500
    timeout_action           = "ForceApplyCapacityChange"
  }

  database_name   = var.rds_dbname
  master_username = tostring(jsondecode(aws_secretsmanager_secret_version.database_credentials.secret_string)["username"])
  master_password = tostring(jsondecode(aws_secretsmanager_secret_version.database_credentials.secret_string)["password"])

  vpc_security_group_ids = [module.vpc.default_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet.name
  availability_zones     = module.vpc.azs

  deletion_protection     = false
  skip_final_snapshot     = true
  backup_retention_period = 7
  apply_immediately       = true

  tags = local.common_tags
}

resource "aws_db_subnet_group" "rds_subnet" {
  name       = "${var.org}-${var.env}-rds-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = local.common_tags
}