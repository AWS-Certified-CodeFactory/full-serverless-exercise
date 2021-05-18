resource "aws_appsync_graphql_api" "app" {
  name                = "${var.org}-${var.env}-api"
  authentication_type = "AMAZON_COGNITO_USER_POOLS"

  user_pool_config {
    aws_region     = var.aws_region
    default_action = "DENY"
    user_pool_id   = aws_cognito_user_pool.app.id
  }
}