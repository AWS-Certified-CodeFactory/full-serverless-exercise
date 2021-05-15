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
  service_registry_arn = aws_service_discovery_service.cluster_registry.arn

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

  cluster_id           = aws_ecs_cluster.main.id
  service_registry_arn = aws_service_discovery_service.cluster_registry.arn

  vpc_id                  = module.vpc.vpc_id
  security_group_id       = module.vpc.default_security_group_id
  subnets                 = module.vpc.private_subnets
  target_group_name       = local.be_target_group_name
  task_execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn           = aws_iam_role.ecs_execution.arn

  //TODO: externalize
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
      name  = "DATASOURCES_DEFAULT_USERNAME"
      value = var.rds_username
    },
    {
      name  = "DATASOURCES_DEFAULT_PASSWORD"
      value = var.rds_password
    },
    {
      name  = "DATASOURCES_DEFAULT_SCHEMA_GENERATE"
      value = "CREATE"
    }
  ]

  common_tags = local.common_tags
}