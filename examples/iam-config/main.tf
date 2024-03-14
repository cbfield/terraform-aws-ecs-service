module "my_ecs_service" {
  source = "../../"

  ecs_service = {
    name = "timmy"
    network_configuration = {
      subnets = ["subnet-123123", "subnet-234234"]
      vpc_id  = "vpc-123123"
    }
  }

  iam = {
    task_role = {
      policies = [{
        name = "allow-s3-read"
        policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Action = [
                "s3:List*",
                "s3:Describe*",
              ]
              Effect   = "Allow"
              Resource = "*"
            },
          ]
        })
      }]
      tags = {
        "tag1" = "value"
      }
    }
    execution_role = {
      policies = [{
        name = "allow-s3-read"
        policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Action = [
                "s3:List*",
                "s3:Describe*",
              ]
              Effect   = "Allow"
              Resource = "*"
            },
          ]
        })
      }]
      tags = {
        "tag1" = "value"
      }
    }
  }
}
