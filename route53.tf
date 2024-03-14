resource "aws_route53_record" "this" {
  count = var.load_balancer.create && var.dns.create ? 1 : 0

  zone_id = var.dns.zone_id
  name    = var.dns.name
  type    = "A"

  alias {
    name                   = aws_lb.this[0].dns_name
    zone_id                = aws_lb.this[0].zone_id
    evaluate_target_health = var.dns.evaluate_target_health
  }
}
