# ECS Task Definitions

# ===================================================================
# Orchestrator Task Definition
# ===================================================================

resource "aws_ecs_task_definition" "orchestrator" {
  family                   = local.orchestrator_task_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.orchestrator_cpu
  memory                   = var.orchestrator_memory
  execution_role_arn       = aws_iam_role.orchestrator_execution.arn
  task_role_arn            = aws_iam_role.orchestrator_task.arn

  container_definitions = jsonencode([
    {
      name      = "orchestrator"
      image     = "${aws_ecr_repository.orchestrator.repository_url}:latest"
      essential = true

      environment = [
        {
          name  = "AWS_DEFAULT_REGION"
          value = local.region
        },
        {
          name  = "DBT_PROJECTS_BUCKET"
          value = aws_s3_bucket.dbt_projects.id
        },
        {
          name  = "ATHENA_WORKGROUP"
          value = local.athena_workgroup
        },
        {
          name  = "ATHENA_OUTPUT_LOCATION"
          value = "s3://${aws_s3_bucket.athena_results.id}/"
        },
        {
          name  = "DBT_RUNNER_TASK_DEFINITION"
          value = local.dbt_runner_task_family
        },
        {
          name  = "ECS_CLUSTER_NAME"
          value = aws_ecs_cluster.main.name
        },
        {
          name  = "DBT_RUNNER_SUBNETS"
          value = jsonencode(data.aws_subnets.default.ids)
        },
        {
          name  = "GLUE_CATALOG_ID"
          value = local.account_id
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.orchestrator.name
          "awslogs-region"        = local.region
          "awslogs-stream-prefix" = "orchestrator"
        }
      }

      portMappings = []
    }
  ])

  tags = local.common_tags
}

# ===================================================================
# dbt Runner Task Definition
# ===================================================================

resource "aws_ecs_task_definition" "dbt_runner" {
  family                   = local.dbt_runner_task_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.dbt_runner_cpu
  memory                   = var.dbt_runner_memory
  execution_role_arn       = aws_iam_role.dbt_runner_execution.arn
  task_role_arn            = aws_iam_role.dbt_runner_task.arn

  container_definitions = jsonencode([
    {
      name      = "dbt-runner"
      image     = "${aws_ecr_repository.dbt_runner.repository_url}:latest"
      essential = true

      environment = [
        {
          name  = "AWS_DEFAULT_REGION"
          value = local.region
        },
        {
          name  = "DBT_PROJECTS_BUCKET"
          value = aws_s3_bucket.dbt_projects.id
        },
        {
          name  = "ATHENA_WORKGROUP"
          value = local.athena_workgroup
        },
        {
          name  = "ATHENA_OUTPUT_LOCATION"
          value = "s3://${aws_s3_bucket.athena_results.id}/"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.dbt_runner.name
          "awslogs-region"        = local.region
          "awslogs-stream-prefix" = "dbt-runner"
        }
      }

      portMappings = []
    }
  ])

  tags = local.common_tags
}
