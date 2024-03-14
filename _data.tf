data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ecs_cluster" "this" {
  count = var.ecs_cluster.use_existing ? 1 : 0

  cluster_name = var.ecs_cluster.name
}
