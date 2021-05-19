module "api" {
  source = "./api"

  org        = var.org
  env        = var.env
  aws_region = var.aws_region

  rds_arn         = aws_rds_cluster.main.arn
  rds_secrets_arn = aws_secretsmanager_secret_version.database_credentials.arn
}