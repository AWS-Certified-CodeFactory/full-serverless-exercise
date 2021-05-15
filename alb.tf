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
    target_group_arn = module.backend_api_gateway.target_group_arn
  }
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