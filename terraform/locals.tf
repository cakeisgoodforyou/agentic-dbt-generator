# Local Values - Simplified and Direct
locals {
  # Account/Region info
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  
  # Direct bucket names (no abstraction layers)
  dbt_projects_bucket   = "${var.project_name}-${var.environment}-dbt-projects"
  athena_results_bucket = "${var.project_name}-${var.environment}-athena-results"
  
  # ECR repositories
  orchestrator_repo = "${var.project_name}-${var.environment}-orchestrator"
  dbt_runner_repo   = "${var.project_name}-${var.environment}-dbt-runner"
  
  # ECS resources
  ecs_cluster_name         = "${var.project_name}-${var.environment}"
  orchestrator_task_family = "${var.project_name}-${var.environment}-orchestrator"
  dbt_runner_task_family   = "${var.project_name}-${var.environment}-dbt-runner"
  
  # Athena (simple, direct)
  athena_workgroup = "${var.project_name}-${var.environment}"
  
  # Common tags
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.additional_tags
  )
}
