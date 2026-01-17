# ECS Cluster and CloudWatch Log Groups

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = local.ecs_cluster_name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = local.common_tags
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "orchestrator" {
  name              = "/ecs/${local.orchestrator_task_family}"
  retention_in_days = 7
  tags = merge(local.common_tags, {
    Purpose = "Orchestrator logs"
  })
}

resource "aws_cloudwatch_log_group" "dbt_runner" {
  name              = "/ecs/${local.dbt_runner_task_family}"
  retention_in_days = 7
  tags = merge(local.common_tags, {
    Purpose = "dbt runner logs"
  })
}
