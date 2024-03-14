module "my_ecs_service" {
  source = "../../"

  ecs_service = {
    name = "timmy"
    alarms = {
      alarm_names = ["alarm1", "alarm2"]
      enable      = true
      rollback    = true
    }
    capacity_provider_strategy = [
      {
        capacity_provider = "my-primary-capacity-provider"
        weight            = 80
      },
      {
        capacity_provider = "my-secondary-capacity-provider"
        weight            = 20
      }
    ]
    deployment_circuit_breaker = {
      enable   = true
      rollback = true
    }
    deployment_controller = {
      type = "CODE_DEPLOY" # or ECS (default) or EXTERNAL
    }
    deployment_maximum_percent         = 200
    deployment_minimum_healthy_percent = 100
    desired_count                      = 3
    enable_ecs_managed_tags            = true
    enable_execute_command             = true
    force_new_deployment               = true
    health_check_grace_period_seconds  = 300
    iam_role                           = "arn:aws:iam:us-west-2:000000000000:role/my-role"
    launch_type                        = "FARGATE" # or EC2 (default) or EXTERNAL. conflicts with capacity_provider_strategy
    load_balancer = {
      container_name = "the-container-with-the-web-server-in-it"
      container_port = 5000
    }
    network_configuration = {
      assign_public_ip = true # defaults to subnet settings
      subnets          = ["subnet-123123", "subnet-234234"]
      vpc_id           = "vpc-123123"
    }
    ordered_placement_strategy = {
      type = "binpack" # or random or spread
      # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#field
      field = "memory" # or cpu
    }
    placement_constraints = [
      {
        type = "memberOf" # or distinctInstance
        # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-query-language.html#expression-examples
        expression = "attribute:ecs.instance-type == t2.small"
      }
    ]
    # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/platform-linux-fargate.html
    platform_version    = "value"
    propagate_tags      = "SERVICE" # or TASK_DEFINITION
    scheduling_strategy = "REPLICA" # or DAEMON
    service_connect_configuration = {
      enabled = true
      # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html
      log_configuration = {
        log_driver = "awslogs"
        options = {
          "option1" = "value1"
        }
        secret_options = [
          {
            name       = "option2"
            value_from = "my-sensitive-ssm-param"
          }
        ]
      }
      namespace = "my-namespace"
      service = {
        client_alias = {
          dns_name = "service1.something.com"
          port     = 5000
        }
        discovery_name        = "my-service-discovery-name"
        ingress_port_override = 5001
        port_name             = "my-port-name"
        timeout = {
          idle_timeout_seconds        = 30
          per_request_timeout_seconds = 5
        }
        tls = {
          issuer_cert_authority = {
            aws_pca_authority_arn = "arn:aws:acm-pca:us-west-2:000000000000:certificate-authority/my-pca"
          }
          kms_key  = "arn:aws:kms:us-west-2:000000000000:key/00000000000"
          role_arn = "arn:aws:iam:us-west-2:000000000000:role/my-role"
        }
      }
    }
    service_registries = [{
      registry_arn = "arn:aws:servicediscovery:us-west-2:000000000000:registry/something"
    }]
    tags = {
      "my-tag" = "value"
    }
    triggers = {
      "my-attribute" = "value"
    }
    wait_for_steady_state = true
  }
}
