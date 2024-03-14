resource "aws_security_group" "load_balancer" {
  count = var.load_balancer.create ? 1 : 0

  name   = "ecs-${local.name}"
  vpc_id = var.load_balancer.vpc_id

  tags = {
    "Name" = "ecs-${local.name}-load-balancer"
  }
}

resource "aws_vpc_security_group_ingress_rule" "load_balancer_ipv4_443" {
  for_each = toset(var.load_balancer.ingress_cidrs_ipv4)

  security_group_id = aws_security_group.load_balancer[0].id
  cidr_ipv4         = each.key
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "load_balancer_ipv6_443" {
  for_each = toset(var.load_balancer.ingress_cidrs_ipv6)

  security_group_id = aws_security_group.load_balancer[0].id
  cidr_ipv6         = each.key
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "load_balancer_ipv4_80" {
  for_each = toset(var.load_balancer.ingress_cidrs_ipv4)

  security_group_id = aws_security_group.load_balancer[0].id
  cidr_ipv4         = each.key
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "load_balancer_ipv6_80" {
  for_each = toset(var.load_balancer.ingress_cidrs_ipv6)

  security_group_id = aws_security_group.load_balancer[0].id
  cidr_ipv6         = each.key
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "lb_to_service" {
  count = var.load_balancer.create ? 1 : 0

  security_group_id            = aws_security_group.load_balancer[0].id
  referenced_security_group_id = aws_security_group.service.id
  ip_protocol                  = "-1"
}

resource "aws_security_group" "service" {
  name   = local.name
  vpc_id = var.ecs_service.network_configuration.vpc_id

  tags = {
    "Name" = "ecs-${local.name}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "lb_to_service" {
  count = var.load_balancer.create ? 1 : 0

  security_group_id            = aws_security_group.service.id
  referenced_security_group_id = aws_security_group.load_balancer[0].id
  ip_protocol                  = "tcp"
  from_port                    = var.ecs_service.load_balancer.container_port
  to_port                      = var.ecs_service.load_balancer.container_port
}

resource "aws_vpc_security_group_egress_rule" "service_allow_all_ipv4" {
  security_group_id = aws_security_group.service.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "service_allow_all_ipv6" {
  security_group_id = aws_security_group.service.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}
