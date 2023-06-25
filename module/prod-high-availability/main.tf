# Creating prod Target Group
resource "aws_lb_target_group" "target_group" {
  name_prefix      = "alb-tg"
  port             = 8080
  protocol         = "HTTP"
  vpc_id           = var.vpc

  health_check {
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 5
  }
}
  
# Created prod Application Load balancer
resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets
  enable_deletion_protection = false
  tags = {
  Name = var.tags
  }
}
  
# Creating prod Load balancer Listener for http
resource "aws_lb_listener" "http-listener" {
  load_balancer_arn      = aws_lb.alb.arn
  port                   = "80"
  protocol               = "HTTP"
  default_action {
    type                 = "forward"
    target_group_arn     = aws_lb_target_group.target_group.arn
    }
  }
  
# Creating prod Load balancer Listener for https access
resource "aws_lb_listener" "https-listener" {
  load_balancer_arn      = aws_lb.alb.arn
  port                   = "443"
  protocol               = "HTTPS"
  ssl_policy             = "ELBSecurityPolicy-2016-08"
  certificate_arn        = var.certificate
  default_action {
    type                 = "forward"
    target_group_arn     = aws_lb_target_group.target_group.arn
  }
}