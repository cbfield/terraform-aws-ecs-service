output "acm_certificate" {
  description = "The ACM certificate managed by this module"
  value       = module.acm_certificate
}

output "aws_caller_identity" {
  description = "The AWS caller identity used to manage this module"
  value       = data.aws_caller_identity.current
}

output "aws_region" {
  description = "The AWS region containing this module"
  value       = data.aws_region.current
}

output "cloudwatch_log_group" {
  description = "The CloudWatch log group managed by this module"
  value       = one(aws_cloudwatch_log_group.this)
}

output "dns_record" {
  description = "The Route53 DNS record managed by this module"
  value       = one(aws_route53_record.this)
}

output "ecs_cluster" {
  description = "The ECS cluster managed or used by this module"
  value       = try(data.aws_ecs_cluster.this[0].cluster_name, aws_ecs_cluster.this[0].name, null)
}

output "ecs_service" {
  description = "The ECS service managed by this module"
  value       = aws_ecs_service.this
}

output "ecs_task_definition" {
  description = "The ECS task definition managed by this module"
  value       = aws_ecs_task_definition.this
}

output "execution_role" {
  description = "The IAM role used when executing ECS tasks"
  value       = aws_iam_role.execution
}

output "task_role" {
  description = "The IAM role used by running ECS tasks in this service"
  value       = aws_iam_role.task
}

output "load_balancer" {
  description = "The load balancer managed by this module"
  value       = one(aws_lb.this)
}

output "load_balancer_security_group" {
  description = "The security group used by the load balancer managed by this module"
  value       = one(aws_security_group.load_balancer)
}

output "service_security_group" {
  description = "The security group used by the ECS service managed by this module"
  value       = aws_security_group.service
}

output "target_group" {
  description = "The load balancer target group managed by this module"
  value       = one(aws_lb_target_group.this)
}
