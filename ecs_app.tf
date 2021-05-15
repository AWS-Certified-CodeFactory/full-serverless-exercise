//TODO: https://www.freecodecamp.org/news/how-to-implement-runtime-environment-variables-with-create-react-app-docker-and-nginx-7f9d42a91d70/

module "backend_api_gateway" {
  source = "./ecs_application"

  image    = "nginx"
  app_name = "frontend"

  cluster_id           = aws_ecs_cluster.main.id
  service_registry_arn = aws_service_discovery_service.cluster_registry.arn

  vpc_id            = module.vpc.vpc_id
  security_group_id = module.vpc.default_security_group_id
  subnets           = module.vpc.private_subnets

  common_tags = local.common_tags
}