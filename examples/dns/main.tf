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
  # the module will create an acm certificate for the given domain
  # and its load balancer will use that, unless another is specified
  load_balancer = {
    vpc_id             = "vpc-123123"
    subnets            = ["subnet-345345", "subnet-456456"]
    ingress_cidrs_ipv4 = ["0.0.0.0/0"]
    ingress_cidrs_ipv6 = ["::/0"]
  }
}
