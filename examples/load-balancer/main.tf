module "my_ecs_service" {
  source = "../../"

  ecs_service = {
    name = "timmy"
    network_configuration = {
      subnets = ["subnet-123123", "subnet-234234"]
      vpc_id  = "vpc-123123"
    }
  }
  load_balancer = {
    acm_certificate_arn = "arn:aws:acm:us-west-2:000000000000:certificate/my-certificate"
    vpc_id              = "vpc-123123"
    subnets             = ["subnet-345345", "subnet-456456"]
    ingress_cidrs_ipv4  = ["0.0.0.0/0"]
    ingress_cidrs_ipv6  = ["::/0"]
  }
}
