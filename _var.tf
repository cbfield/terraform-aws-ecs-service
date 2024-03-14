variable "acm_certificate" {
  description = "Configurations for an ACM certificate used to encrypt service traffic"
  type = object({
    create            = optional(bool, true)
    domain            = optional(string)
    zone_id           = optional(string)
    validate          = optional(bool, true)
    validation_method = optional(string, "DNS")
  })
  default = {
    create = true
  }
}

variable "cloudwatch_log_group" {
  description = "Configurations for a CloudWatch log group associated with the ECS cluster, if created by this module"
  type = object({
    create            = optional(bool, true)
    retention_in_days = optional(number, 7)
    log_group_class   = optional(string)
    kms_key_id        = optional(string)
    skip_destroy      = optional(bool)
    tags              = optional(map(string), {})
  })
  default = {}
}

variable "dns" {
  description = "Configurations for the DNS record managed by this module"
  type = object({
    name                   = optional(string)
    zone_id                = optional(string)
    evaluate_target_health = optional(bool, true)
    create                 = optional(bool, true)
  })
  default = {
    create = false
  }
  validation {
    condition     = (!var.dns.create) || (var.dns.name != null && var.dns.zone_id != null)
    error_message = "The attributes 'name' and 'zone_id' must be provided when 'create' is true."
  }
}

variable "ecs_cluster" {
  description = "Configurations for the ECS cluster used/ managed by this module"
  type = object({
    name         = optional(string, "main")
    use_existing = optional(bool, false)
    tags         = optional(map(string), {})
    configuration = optional(object({
      execute_command_configuration = optional(object({
        kms_key_id = optional(string)
        log_configuration = optional(object({
          cloud_watch_encryption_enabled = optional(bool)
          cloud_watch_log_group_name     = optional(string)
          s3_bucket_name                 = optional(string)
          s3_bucket_encryption_enabled   = optional(bool)
          s3_key_prefix                  = optional(string)
        }))
        logging = optional(string)
      }))
    }))
    service_connect_defaults = optional(object({
      namespace = string
    }))
    settings = optional(list(object({
      name  = string
      value = string
    })), [])
  })
  default = {}
}

variable "ecs_service" {
  description = "Configurations for the ECS service managed by this module"
  type = object({
    name                               = optional(string)
    desired_count                      = optional(number, 1)
    enable_ecs_managed_tags            = optional(bool, true)
    enable_execute_command             = optional(bool, true)
    force_new_deployment               = optional(bool)
    wait_for_steady_state              = optional(bool)
    launch_type                        = optional(string, "FARGATE")
    propagate_tags                     = optional(string, "SERVICE")
    deployment_maximum_percent         = optional(number)
    deployment_minimum_healthy_percent = optional(number)
    health_check_grace_period_seconds  = optional(number)
    platform_version                   = optional(string)
    scheduling_strategy                = optional(string)
    iam_role                           = optional(string)
    tags                               = optional(map(string))
    triggers                           = optional(map(string))
    alarms = optional(object({
      alarm_names = list(string)
      enable      = bool
      rollback    = bool
    }))
    capacity_provider_strategy = optional(list(object({
      base              = optional(number)
      capacity_provider = string
      weight            = number
    })), [])
    deployment_circuit_breaker = optional(object({
      enable   = bool
      rollback = bool
    }))
    deployment_controller = optional(object({
      type = optional(string)
    }), {})
    load_balancer = optional(object({
      container_name = optional(string)
      container_port = optional(number, 5000)
    }), {})
    network_configuration = object({
      subnets          = list(string)
      vpc_id           = string
      security_groups  = optional(list(string), [])
      assign_public_ip = optional(bool)
    })
    ordered_placement_strategy = optional(object({
      type  = string
      field = optional(string)
    }))
    placement_constraints = optional(list(object({
      type       = string
      expression = optional(string)
    })), [])
    service_registries = optional(list(object({
      registry_arn   = string
      port           = optional(number)
      container_port = optional(number)
      container_name = optional(string)
    })), [])
    service_connect_configuration = optional(object({
      enabled = bool
      log_configuration = optional(object({
        log_driver = string
        options    = map(string)
        secret_options = list(object({
          name       = string
          value_from = string
        }))
      }))
      namespace = optional(string)
      service = optional(object({
        discovery_name        = optional(string)
        ingress_port_override = optional(number)
        port_name             = string
        client_alias = optional(object({
          dns_name = optional(string)
          port     = number
        }))
        timeout = optional(object({
          idle_timeout_seconds        = optional(number)
          per_request_timeout_seconds = optional(number)
        }), {})
        tls = optional(object({
          issuer_cert_authority = object({
            aws_pca_authority_arn = optional(string)
          })
          kms_key  = optional(string)
          role_arn = optional(string)
        }))
      }))
    }))
  })
}

variable "ecs_task_definition" {
  description = "Configurations for the ECS task definition managed by this module"
  type = object({
    family                   = optional(string, "main")
    image                    = optional(string, "hello-world")
    container_definitions    = optional(string)
    cpu                      = optional(number, 256)
    memory                   = optional(number, 512)
    execution_role_arn       = optional(string)
    task_role_arn            = optional(string)
    ipc_mode                 = optional(string)
    pid_mode                 = optional(string)
    network_mode             = optional(string, "awsvpc")
    requires_compatibilities = optional(list(string), ["FARGATE"])
    skip_destroy             = optional(bool)
    track_latest             = optional(bool)
    tags                     = optional(map(string), {})
  })
  default = {}
}

variable "iam" {
  description = "Configurations for the IAM roles managed by this module"
  type = object({
    execution_role = optional(object({
      policies = optional(list(object({
        name   = string
        policy = string
      })), [])
      tags = optional(map(string))
    }), {})
    task_role = optional(object({
      policies = optional(list(object({
        name   = string
        policy = string
      })), [])
      tags = optional(map(string))
    }), {})
  })
  default = {}
}

variable "load_balancer" {
  description = "Configurations for the load balancer used/ managed by this module"
  type = object({
    vpc_id              = optional(string)
    subnets             = optional(list(string))
    internal            = optional(bool)
    create              = optional(bool, true)
    security_groups     = optional(list(string), [])
    ssl_policy          = optional(string, "ELBSecurityPolicy-TLS-1-2-Ext-2018-06")
    acm_certificate_arn = optional(string)
    target_type         = optional(string, "ip")
    ingress_cidrs_ipv4  = optional(list(string), [])
    ingress_cidrs_ipv6  = optional(list(string), [])
  })
  default = {
    create = false
  }
}
