resource "aws_ecs_cluster" "main" {
  name = "${var.org}-${var.env}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.common_tags
}

resource "aws_service_discovery_private_dns_namespace" "internal" {
  name        = "${var.org}.${var.env}.local"
  description = "internal dns for ${var.org}.${var.env}"
  vpc         = module.vpc.vpc_id
}

resource "aws_service_discovery_service" "cluster_registry" {
  name = "${var.org}-${var.env}-ecs-cluster-registry"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.internal.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

//TODO: https://www.freecodecamp.org/news/how-to-implement-runtime-environment-variables-with-create-react-app-docker-and-nginx-7f9d42a91d70/
resource "aws_ecs_task_definition" "website" {
  family = "website"

  container_definitions = jsonencode([
    {
      name      = "website"
      image     = "nginx"
      cpu       = 100
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]

  tags = local.common_tags
}

resource "aws_ecs_service" "website" {
  name            = "website"
  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.website.arn
  desired_count   = 4

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [module.vpc.default_security_group_id]
    assign_public_ip = false
  }

  //  health_check_grace_period_seconds = 30

  //  load_balancer {
  //    container_name = ""
  //    container_port = 0
  //  }

  service_registries {
    registry_arn   = aws_service_discovery_service.cluster_registry.arn
    container_name = "website"
  }

  tags = local.common_tags
}