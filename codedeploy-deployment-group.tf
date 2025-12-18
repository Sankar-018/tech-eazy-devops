resource "aws_codedeploy_deployment_group" "tech_eazy_dg" {
  app_name              = aws_codedeploy_app.tech_eazy.name
  deployment_group_name = "tech-eazy-dg-${var.stage}"
  service_role_arn      = aws_iam_role.codedeploy_service_role.arn

  autoscaling_groups = [
    aws_autoscaling_group.app_asg.name
  ]

  deployment_style {
    deployment_type   = "IN_PLACE"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  load_balancer_info {
    target_group_info {
      name = aws_lb_target_group.app_tg.name
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}
