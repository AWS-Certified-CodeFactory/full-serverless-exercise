resource "aws_secretsmanager_secret" "database_credentials" {
  name                    = "${var.org}-${var.env}-database-credentials"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "database_credentials" {
  secret_id = aws_secretsmanager_secret.database_credentials.id

  secret_string = jsonencode({
    username = var.rds_username
    password = random_password.database_password.result
  })
}

resource "random_password" "database_password" {
  length  = 32
  special = false
}