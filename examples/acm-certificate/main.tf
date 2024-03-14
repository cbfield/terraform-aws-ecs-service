module "my_ecs_service" {
  source = "../../"

  ecs_service = {
    name = "timmy"
    network_configuration = {
      subnets = ["subnet-123123", "subnet-234234"]
      vpc_id  = "vpc-123123"
    }
  }
  dns = {
    name    = "something.mydomain.com"
    zone_id = "000000000000"
  }
  # if the `acm_certificate` argument is omitted, a certificate
  # for `something.mydomain.com` will be created (because of var.dns.name)
  acm_certificate = {
    domain  = "*.mydomain.com"
    zone_id = "000000000000"
  }
  load_balancer = {
    vpc_id             = "vpc-123123"
    subnets            = ["subnet-345345", "subnet-456456"]
    ingress_cidrs_ipv4 = ["0.0.0.0/0"]
    ingress_cidrs_ipv6 = ["::/0"]
  }
}
