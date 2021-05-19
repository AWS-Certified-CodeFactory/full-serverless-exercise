//use this guide:
//https://docs.aws.amazon.com/appsync/latest/devguide/tutorial-rds-resolvers.html

resource "aws_appsync_datasource" "rds" {
  api_id           = aws_appsync_graphql_api.app.id
  name             = "rds"
  description      = "relational database connectivity"
  type             = "RELATIONAL_DATABASE"
  service_role_arn = aws_iam_role.rds_access.arn
}

resource "aws_iam_role" "rds_access" {
  name               = "${var.org}-${var.env}-rds-ds-access"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "appsync.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "rds_access" {
  role   = aws_iam_role.rds_access.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "rds-data:DeleteItems",
        "rds-data:ExecuteSql",
        "rds-data:ExecuteStatement",
        "rds-data:GetItems",
        "rds-data:InsertItems",
        "rds-data:UpdateItems"
      ],
      "Effect": "Allow",
      "Resource": [
        "${var.rds_arn}",
        "${var.rds_arn}:*"
      ]
    },
    {
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Effect": "Allow",
      "Resource": [
        "${var.rds_secrets_arn}",
        "${var.rds_secrets_arn}:*"
      ]
    }
  ]
}
EOF
}