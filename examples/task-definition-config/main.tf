module "my_ecs_service" {
  source = "../../"

  ecs_service = {
    name = "timmy"
    network_configuration = {
      subnets = ["subnet-123123", "subnet-234234"]
      vpc_id  = "vpc-123123"
    }
  }

  ecs_task_definition = {
    family                   = "my-app"
    image                    = "cbfield/dev:latest"
    cpu                      = 256
    memory                   = 512
    execution_role_arn       = "arn:aws:iam:us-west-2:000000000000:role/my-role"
    task_role_arn            = "arn:aws:iam:us-west-2:000000000000:role/my-role"
    ipc_mode                 = "host"   # or task or none
    pid_mode                 = "host"   # or task
    network_mode             = "awsvpc" # or bridge or host or none
    requires_compatibilities = ["FARGATE"]
    skip_destroy             = false
    track_latest             = false
    tags = {
      "tag1" = "value"
    }
    container_definitions = jsonencode([
      {
        name      = "my-app"
        image     = "cbfield/dev:latest"
        cpu       = 256
        memory    = 512
        essential = true
        portMappings = [
          {
            containerPort = 5000
            hostPort      = 5000
          }
        ]
      }
    ])
  }
}
