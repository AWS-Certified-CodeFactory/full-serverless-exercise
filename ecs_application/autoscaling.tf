resource "aws_appautoscaling_target" "app" {
  max_capacity       = var.desired_count
  min_capacity       = 2
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "app" {
  name        = "${var.org}-${var.env}-ecs-asp-${var.app_name}"
  policy_type = "TargetTrackingScaling"

  resource_id        = aws_appautoscaling_target.app.resource_id
  scalable_dimension = aws_appautoscaling_target.app.scalable_dimension
  service_namespace  = aws_appautoscaling_target.app.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 50
    scale_in_cooldown  = 120
    scale_out_cooldown = 10
  }
}