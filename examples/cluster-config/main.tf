module "my_ecs_service" {
  source = "../../"

  ecs_service = {
    name = "timmy"
    network_configuration = {
      subnets = ["subnet-123123", "subnet-234234"]
      vpc_id  = "vpc-123123"
    }
  }

  ecs_cluster = {
    configuration = {
      execute_command_configuration = {
        kms_key_id = "00000000-0000-0000-0000-000000000000"
        logging    = "OVERRIDE"
        log_configuration = {
          cloud_watch_encryption_enabled = true
          s3_bucket_encryption_enabled   = true
          s3_bucket_name                 = "my-bucket"
          cloud_watch_log_group_name     = "my-log-group" # omit to use the log group created by the module
        }
      }
    }
    settings = [{
      name  = "containerInsights"
      value = "enabled"
    }]
  }

  cloudwatch_log_group = {
    kms_key_id        = "00000000-0000-0000-0000-000000000000"
    retention_in_days = 30
    skip_destroy      = true
    tags = {
      "tag1" = "value"
    }
  }

  # The following can be used to deploy an ECS service into
  # an existing cluster, instead of creating a new one
  # ecs_cluster = {
  #   use_existing = "my-cluster-name"
  # }
}
