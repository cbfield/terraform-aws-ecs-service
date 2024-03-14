resource "aws_iam_role" "task" {
  name = "ecs-${local.name}-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:ecs:us-west-2:${data.aws_caller_identity.current.id}:*"
          },
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.id
          }
        }
      }
    ]
  })
  tags = var.iam.task_role.tags
}

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html#create_task_iam_policy_and_role
resource "aws_iam_role_policy" "task" {
  role = aws_iam_role.task.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "execution" {
  name = "ecs-${local.name}-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  tags = var.iam.execution_role.tags
}

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
resource "aws_iam_role_policy" "execution" {
  role = aws_iam_role.execution.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "execution_extras" {
  for_each = { for policy in var.iam.execution_role.policies : policy.name => policy }

  role   = aws_iam_role.execution.name
  policy = each.value.policy
}

resource "aws_iam_role_policy" "task_extras" {
  for_each = { for policy in var.iam.task_role.policies : policy.name => policy }

  role   = aws_iam_role.task.name
  policy = each.value.policy
}
