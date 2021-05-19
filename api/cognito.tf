resource "aws_cognito_user_pool" "app" {
  name = "${var.org}-${var.env}-app-user-pool"
}

resource "aws_cognito_user_pool_client" "app_ios" {
  name         = "ios"
  user_pool_id = aws_cognito_user_pool.app.id
}