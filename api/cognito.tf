resource "aws_cognito_user_pool" "app" {
  name = "${var.org}-${var.env}-app-user-pool"
}