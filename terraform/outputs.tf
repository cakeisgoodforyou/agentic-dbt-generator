# Outputs

output "project_name" { 
    value = var.project_name 
}

output "environment" { 
    value = var.environment 
}

output "aws_region" { 
    value = local.region 
}

output "vpc_subnets" { 
    value = join(",", data.aws_subnets.default.ids) 
}

output "dbt_projects_bucket" {
  description = "S3 bucket for dbt projects"
  value       = aws_s3_bucket.dbt_projects.id
}

output "athena_results_bucket" {
  description = "S3 bucket for Athena query results"
  value       = aws_s3_bucket.athena_results.id
}

# ECR
output "orchestrator_repository_url" {
  description = "ECR repository URL for orchestrator"
  value       = aws_ecr_repository.orchestrator.repository_url
}

output "dbt_runner_repository_url" {
  description = "ECR repository URL for dbt runner"
  value       = aws_ecr_repository.dbt_runner.repository_url
}

# ECS
output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "orchestrator_task_definition_arn" {
  description = "Orchestrator task definition ARN"
  value       = aws_ecs_task_definition.orchestrator.arn
}

output "dbt_runner_task_definition_arn" {
  description = "dbt runner task definition ARN"
  value       = aws_ecs_task_definition.dbt_runner.arn
}

# Athena
output "athena_workgroup" {
  description = "Athena workgroup name"
  value       = aws_athena_workgroup.dbt_agent.name
}

# Deployment commands
output "docker_login_command" {
  description = "Command to login to ECR"
  value       = "aws ecr get-login-password --region ${local.region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${local.region}.amazonaws.com"
}

output "run_orchestrator_command" {
  description = "Command to run orchestrator task"
  value = <<-EOT
    aws ecs run-task \
      --cluster ${aws_ecs_cluster.main.name} \
      --task-definition ${aws_ecs_task_definition.orchestrator.family} \
      --launch-type FARGATE \
      --network-configuration "awsvpcConfiguration={subnets=[${join(",", data.aws_subnets.default.ids)}],assignPublicIp=ENABLED}" \
      --region ${local.region}
  EOT
}

# Example with environment overrides
output "run_orchestrator_with_config_example" {
  description = "Example command to run orchestrator with custom config"
  value = <<-EOT
    aws ecs run-task \
      --cluster ${aws_ecs_cluster.main.name} \
      --task-definition ${aws_ecs_task_definition.orchestrator.family} \
      --launch-type FARGATE \
      --network-configuration "awsvpcConfiguration={subnets=[${join(",", data.aws_subnets.default.ids)}],assignPublicIp=ENABLED}" \
      --overrides '{
        "containerOverrides": [{
          "name": "orchestrator",
          "environment": [
            {"name": "INPUT_DATABASE", "value": "raw"},
            {"name": "INPUT_TABLES", "value": "customers,orders"}
          ]
        }]
      }' \
      --region ${local.region}
  EOT
}
