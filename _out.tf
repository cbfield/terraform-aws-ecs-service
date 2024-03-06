output "aws_caller_identity" {
  description = "The AWS caller identity used to manage this module"
  value       = data.aws_caller_identity.current
}

output "aws_region" {
  description = "The AWS region containing this module"
  value       = data.aws_region.current
}
