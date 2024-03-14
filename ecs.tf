resource "random_pet" "name" {
  count = var.ecs_service.name == null ? 1 : 0
}

locals {
  name = coalesce(var.ecs_service.name, try(random_pet.name[0].id, null))
}

resource "aws_ecs_cluster" "this" {
  count = var.ecs_cluster.use_existing ? 0 : 1

  name = local.name
  tags = var.ecs_cluster.tags

  dynamic "configuration" {
    for_each = var.ecs_cluster.configuration != null ? toset([1]) : toset([])
    content {
      dynamic "execute_command_configuration" {
        for_each = var.ecs_cluster.configuration.execute_command_configuration != null ? toset([1]) : toset([])
        content {
          kms_key_id = var.ecs_cluster.configuration.execute_command_configuration.kms_key_id
          logging    = var.ecs_cluster.configuration.execute_command_configuration.logging

          log_configuration {
            cloud_watch_encryption_enabled = var.ecs_cluster.configuration.execute_command_configuration.log_configuration.cloud_watch_encryption_enabled
            cloud_watch_log_group_name     = coalesce(var.ecs_cluster.configuration.execute_command_configuration.log_configuration.cloud_watch_log_group_name, aws_cloudwatch_log_group.this[0].name)
            s3_bucket_name                 = var.ecs_cluster.configuration.execute_command_configuration.log_configuration.s3_bucket_name
            s3_bucket_encryption_enabled   = var.ecs_cluster.configuration.execute_command_configuration.log_configuration.s3_bucket_encryption_enabled
            s3_key_prefix                  = var.ecs_cluster.configuration.execute_command_configuration.log_configuration.s3_key_prefix
          }
        }
      }
    }
  }

  dynamic "service_connect_defaults" {
    for_each = var.ecs_cluster.service_connect_defaults != null ? toset([1]) : toset([])
    content {
      namespace = var.ecs_cluster.configuration.service_connect_defaults.namespace
    }
  }

  dynamic "setting" {
    for_each = { for setting in var.ecs_cluster.settings : "${setting.name}:${setting.value}" => setting }
    content {
      name  = setting.value.name
      value = setting.value.value
    }
  }
}

resource "aws_ecs_service" "this" {
  name                               = var.ecs_service.name
  cluster                            = try(data.aws_ecs_cluster.this[0].cluster_name, aws_ecs_cluster.this[0].name, null)
  task_definition                    = aws_ecs_task_definition.this.arn
  desired_count                      = var.ecs_service.desired_count
  enable_ecs_managed_tags            = var.ecs_service.enable_ecs_managed_tags
  enable_execute_command             = var.ecs_service.enable_execute_command
  force_new_deployment               = var.ecs_service.force_new_deployment
  wait_for_steady_state              = var.ecs_service.wait_for_steady_state
  launch_type                        = var.ecs_service.launch_type
  propagate_tags                     = var.ecs_service.propagate_tags
  deployment_maximum_percent         = var.ecs_service.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.ecs_service.deployment_minimum_healthy_percent
  health_check_grace_period_seconds  = var.ecs_service.health_check_grace_period_seconds
  platform_version                   = var.ecs_service.platform_version
  scheduling_strategy                = var.ecs_service.scheduling_strategy
  iam_role                           = var.ecs_service.iam_role
  tags                               = var.ecs_service.tags
  triggers                           = var.ecs_service.triggers

  dynamic "alarms" {
    for_each = var.ecs_service.alarms != null ? toset([1]) : toset([])
    content {
      alarm_names = var.ecs_service.alarms.alarm_names
      enable      = var.ecs_service.alarms.enable
      rollback    = var.ecs_service.alarms.rollback
    }
  }

  dynamic "capacity_provider_strategy" {
    for_each = { for strategy in var.ecs_service.capacity_provider_strategy : "${coalesce(strategy.base, 0)}:${strategy.capacity_provider}:${strategy.weight}" => strategy }
    content {
      base              = capacity_provider_strategy.value.base
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
    }
  }

  dynamic "deployment_circuit_breaker" {
    for_each = var.ecs_service.deployment_circuit_breaker != null ? toset([1]) : toset([])
    content {
      enable   = var.ecs_service.deployment_circuit_breaker.enable
      rollback = var.ecs_service.deployment_circuit_breaker.rollback
    }
  }

  dynamic "deployment_controller" {
    for_each = var.ecs_service.deployment_controller != null ? toset([1]) : toset([])
    content {
      type = var.ecs_service.deployment_controller.type
    }
  }

  dynamic "ordered_placement_strategy" {
    for_each = var.ecs_service.ordered_placement_strategy != null ? toset([1]) : toset([])
    content {
      type  = var.ecs_service.ordered_placement_strategy.type
      field = var.ecs_service.ordered_placement_strategy.field
    }
  }

  dynamic "placement_constraints" {
    for_each = { for constraint in var.ecs_service.placement_constraints : "${constraint.type}:${constraint.expression}" => constraint }
    content {
      type       = placement_constraints.value.type
      expression = placement_constraints.value.expression
    }
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer.create && var.ecs_service.load_balancer != null ? toset([1]) : toset([])
    content {
      target_group_arn = aws_lb_target_group.this[0].arn
      container_name   = coalesce(var.ecs_service.load_balancer.container_name, var.ecs_service.name)
      container_port   = var.ecs_service.load_balancer.container_port
    }
  }

  dynamic "network_configuration" {
    for_each = var.ecs_service.network_configuration != null ? toset([1]) : toset([])
    content {
      subnets          = var.ecs_service.network_configuration.subnets
      security_groups  = concat(var.ecs_service.network_configuration.security_groups, [aws_security_group.service.id])
      assign_public_ip = var.ecs_service.network_configuration.assign_public_ip
    }
  }

  dynamic "service_registries" {
    for_each = { for registry in var.ecs_service.service_registries : "" => registry }
    content {
      registry_arn   = service_registries.value.registry_arn
      port           = service_registries.value.port
      container_port = service_registries.value.container_port
      container_name = service_registries.value.container_name
    }
  }

  dynamic "service_connect_configuration" {
    for_each = var.ecs_service.service_connect_configuration != null ? toset([1]) : toset([])
    content {
      enabled   = var.ecs_service.service_connect_configuration.enabled
      namespace = var.ecs_service.service_connect_configuration.namespace

      dynamic "log_configuration" {
        for_each = var.ecs_service.service_connect_configuration.log_configuration != null ? toset([1]) : toset([])
        content {
          log_driver = var.ecs_service.service_connect_configuration.log_configuration.log_driver
          options    = var.ecs_service.service_connect_configuration.log_configuration.options

          dynamic "secret_option" {
            for_each = { for option in var.ecs_service.service_connect_configuration.log_configuration.secret_options : "${option.name}:${option.value_from}" => option }
            content {
              name       = secret_option.value.name
              value_from = secret_option.value.value_from
            }
          }
        }
      }

      dynamic "service" {
        for_each = var.ecs_service.service_connect_configuration.service != null ? toset([1]) : toset([])
        content {
          discovery_name        = var.ecs_service.service_connect_configuration.service.discovery_name
          ingress_port_override = var.ecs_service.service_connect_configuration.service.ingress_port_override
          port_name             = var.ecs_service.service_connect_configuration.service.port_name

          dynamic "client_alias" {
            for_each = var.ecs_service.service_connect_configuration.service.client_alias != null ? toset([1]) : toset([])
            content {
              dns_name = var.ecs_service.service_connect_configuration.service.client_alias.dns_name
              port     = var.ecs_service.service_connect_configuration.service.client_alias.port
            }
          }

          dynamic "timeout" {
            for_each = var.ecs_service.service_connect_configuration.service.timeout != null ? toset([1]) : toset([])
            content {
              idle_timeout_seconds        = var.ecs_service.service_connect_configuration.service.timeout.idle_timeout_seconds
              per_request_timeout_seconds = var.ecs_service.service_connect_configuration.service.timeout.per_request_timeout_seconds
            }
          }

          dynamic "tls" {
            for_each = var.ecs_service.service_connect_configuration.service.tls != null ? toset([1]) : toset([])
            content {
              kms_key  = var.ecs_service.service_connect_configuration.service.tls.kms_key
              role_arn = var.ecs_service.service_connect_configuration.service.tls.role_arn

              dynamic "issuer_cert_authority" {
                for_each = var.ecs_service.service_connect_configuration.service.tls.issuer_cert_authority != null ? toset([1]) : toset([])
                content {
                  aws_pca_authority_arn = var.ecs_service.service_connect_configuration.service.tls.issuer_cert_authority.aws_pca_authority_arn
                }
              }
            }
          }
        }
      }
    }
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.ecs_task_definition.family
  cpu                      = var.ecs_task_definition.cpu
  memory                   = var.ecs_task_definition.memory
  execution_role_arn       = coalesce(var.ecs_task_definition.execution_role_arn, try(aws_iam_role.execution.arn, null))
  task_role_arn            = coalesce(var.ecs_task_definition.execution_role_arn, try(aws_iam_role.task.arn, null))
  requires_compatibilities = var.ecs_task_definition.requires_compatibilities
  ipc_mode                 = var.ecs_task_definition.ipc_mode
  pid_mode                 = var.ecs_task_definition.pid_mode
  network_mode             = var.ecs_task_definition.network_mode
  skip_destroy             = var.ecs_task_definition.skip_destroy
  track_latest             = var.ecs_task_definition.track_latest
  tags                     = var.ecs_task_definition.tags

  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size
  container_definitions = coalesce(var.ecs_task_definition.container_definitions, jsonencode([
    {
      name      = var.ecs_service.name
      image     = var.ecs_task_definition.image
      cpu       = var.ecs_task_definition.cpu
      memory    = var.ecs_task_definition.memory
      essential = true
      portMappings = [
        {
          containerPort = var.ecs_service.load_balancer.container_port
          hostPort      = var.ecs_service.load_balancer.container_port
        }
      ]
  }]))
}
