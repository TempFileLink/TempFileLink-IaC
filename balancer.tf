resource "aws_lb" "ecs_alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.alb_sg.security_group_id]
  subnets            = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]

  tags = merge({
    Name = "ecs-alb"
  }, local.common_tags)
}

resource "aws_lb_listener" "ecs_alb_listener_http" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = length(aws_acm_certificate.cert) == 1 ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.ecs_tg.arn
    }
  }

  dynamic "default_action" {
    for_each = length(aws_acm_certificate.cert) == 1 ? [1] : []
    content {
      type = "redirect"

      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }
}

resource "aws_lb_listener" "ecs_alb_listener_https" {
  count             = length(aws_acm_certificate.cert)
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert[0].arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

resource "aws_lb_target_group" "ecs_tg" {
  name        = "my-ecs-target-group"
  vpc_id      = module.vpc.vpc_id
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"

  health_check {
    path = "/"
  }
}
