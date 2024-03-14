module "acm_certificate" {
  source  = "app.terraform.io/cbfield/acm-certificate/aws"
  version = "2.0.0"
  count   = var.dns.create && var.acm_certificate.create ? 1 : 0

  domain            = coalesce(var.acm_certificate.domain, var.dns.name)
  zone_id           = coalesce(var.acm_certificate.zone_id, var.dns.zone_id)
  validate          = var.acm_certificate.validate
  validation_method = var.acm_certificate.validation_method
}
