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