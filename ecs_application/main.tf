resource "aws_ecs_task_definition" "app" {
  family = var.app_name

  container_definitions = jsonencode([
    {
      name      = var.app_name
      image     = var.image
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ],
      environment = var.environment_variables
      secrets     = var.secrets
    }
  ])

  network_mode             = "awsvpc"
  cpu                      = var.cpu_container
  memory                   = var.memory_container
  requires_compatibilities = ["FARGATE"]

  task_role_arn      = var.task_role_arn
  execution_role_arn = var.task_execution_role_arn

}

resource "aws_ecs_service" "app" {
  name            = var.app_name
  launch_type     = "FARGATE"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count

  network_configuration {
    subnets          = var.subnets
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  health_check_grace_period_seconds = 30

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = var.app_name
    container_port   = 80
  }

  service_registries {
    registry_arn   = var.service_registry_arn
    container_name = var.app_name
  }

  tags = var.common_tags
}

resource "aws_lb_target_group" "app" {
  name        = var.target_group_name
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
}