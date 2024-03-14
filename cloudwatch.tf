resource "aws_cloudwatch_log_group" "this" {
  count = var.cloudwatch_log_group.create ? 1 : 0

  name_prefix       = local.name
  retention_in_days = var.cloudwatch_log_group.retention_in_days
  log_group_class   = var.cloudwatch_log_group.log_group_class
  kms_key_id        = var.cloudwatch_log_group.kms_key_id
  skip_destroy      = var.cloudwatch_log_group.skip_destroy
  tags              = var.cloudwatch_log_group.tags
}
