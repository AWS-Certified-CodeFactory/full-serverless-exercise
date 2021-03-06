//TODO: https://www.freecodecamp.org/news/how-to-implement-runtime-environment-variables-with-create-react-app-docker-and-nginx-7f9d42a91d70/

locals {
  fe_target_group_name = "frontend"
  be_target_group_name = "api"
}

module "frontend_website" {
  source = "./ecs_application"

  image    = "nginx"
  app_name = "frontend-website"

  cluster_id           = aws_ecs_cluster.main.id
  cluster_name         = aws_ecs_cluster.main.name
  service_registry_arn = aws_service_discovery_service.cluster_registry.arn

  desired_count = 6

  vpc_id                  = module.vpc.vpc_id
  security_group_id       = module.vpc.default_security_group_id
  subnets                 = module.vpc.private_subnets
  target_group_name       = local.fe_target_group_name
  task_execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn           = aws_iam_role.ecs_execution.arn

  common_tags = local.common_tags
}

module "backend_api_gateway" {
  source = "./ecs_application"

  image    = "${var.ecr_repo}/fs-aws.api_gateway"
  app_name = "backend-api-gateway"

  cpu              = 512
  cpu_container    = "1024"
  memory           = 1024
  memory_container = "2048"
  desired_count    = 10

  cluster_id           = aws_ecs_cluster.main.id
  cluster_name         = aws_ecs_cluster.main.name
  service_registry_arn = aws_service_discovery_service.cluster_registry.arn

  vpc_id                  = module.vpc.vpc_id
  security_group_id       = module.vpc.default_security_group_id
  subnets                 = module.vpc.private_subnets
  target_group_name       = local.be_target_group_name
  task_execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn           = aws_iam_role.ecs_execution.arn

  environment_variables = [
    {
      name  = "MICRONAUT_SERVER_PORT"
      value = "80"
    },
    {
      name  = "DATASOURCES_DEFAULT_URL"
      value = "jdbc:postgresql://${aws_rds_cluster.main.endpoint}:5432/${var.rds_dbname}"
    },
    {
      name  = "DATASOURCES_DEFAULT_SCHEMA_GENERATE"
      value = "CREATE"
    }
  ]

  secrets = [
    {
      name      = "DATASOURCES_DEFAULT_USERNAME"
      valueFrom = "${aws_secretsmanager_secret_version.database_credentials.arn}:username::"
    },
    {
      name      = "DATASOURCES_DEFAULT_PASSWORD"
      valueFrom = "${aws_secretsmanager_secret_version.database_credentials.arn}:password::"
    }
  ]

  health_http_code = "404"

  common_tags = local.common_tags
}
