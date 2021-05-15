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

  health_check_grace_period_seconds = 30

  load_balancer {
    target_group_arn = aws_lb_target_group.cluster_ingress_http.arn
    container_name   = "website"
    container_port   = 80
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.cluster_registry.arn
    container_name = "website"
  }

  tags = local.common_tags
}

resource "aws_lb" "cluster_ingress" {
  name               = "${var.org}-${var.env}-cluster-ingress-alb"
  load_balancer_type = "application"
  internal           = false

  security_groups = [aws_security_group.cluster_ingress.id]
  subnets         = module.vpc.public_subnets

  tags = local.common_tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.cluster_ingress.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cluster_ingress_http.arn
  }
}

resource "aws_lb_target_group" "cluster_ingress_http" {
  name        = "${var.org}-${var.env}-http"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "cluster_ingress" {
  name        = "${var.org}-${var.env}-cluster-alb-sg"
  description = "Allow traffic into the ECS cluster ingress"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_security_group_rule" "lb_to_cluster" {
  description              = "ALB access to the cluster"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = module.vpc.default_security_group_id
  source_security_group_id = aws_security_group.cluster_ingress.id
  type                     = "ingress"
}