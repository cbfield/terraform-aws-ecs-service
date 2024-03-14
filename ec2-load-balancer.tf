resource "aws_lb" "this" {
  count = var.load_balancer.create ? 1 : 0

  name_prefix        = substr(local.name, 0, 6)
  internal           = var.load_balancer.internal
  load_balancer_type = "application"
  security_groups    = concat(var.load_balancer.security_groups, [aws_security_group.load_balancer[0].id])
  subnets            = var.load_balancer.subnets
}

resource "aws_lb_listener" "port_443" {
  count = var.load_balancer.create ? 1 : 0

  load_balancer_arn = aws_lb.this[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.load_balancer.ssl_policy
  certificate_arn   = coalesce(var.load_balancer.acm_certificate_arn, try(module.acm_certificate[0].certificate.arn, null))

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }
}

resource "aws_lb_listener" "port_80" {
  count = var.load_balancer.create ? 1 : 0

  load_balancer_arn = aws_lb.this[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "this" {
  count = var.load_balancer.create ? 1 : 0

  name_prefix = substr(local.name, 0, 6)
  port        = var.ecs_service.load_balancer.container_port
  protocol    = "HTTP"
  target_type = var.load_balancer.target_type
  vpc_id      = var.load_balancer.vpc_id
}
