#############################################
# APPLICATION LOAD BALANCER
#############################################

resource "aws_lb" "app_lb" {
  name               = "tech-eazy-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]

  # Use filtered subnets (ap-south-1a & 1b only)
  subnets = data.aws_subnets.available.ids
}

#############################################
# TARGET GROUP
#############################################

resource "aws_lb_target_group" "app_tg" {
  name     = "tech-eazy-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path     = "/hello"   # Spring MVC endpoint
    matcher  = "200-399"
    interval = 30
    timeout  = 5
  }
}

#############################################
# LISTENER
#############################################

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
