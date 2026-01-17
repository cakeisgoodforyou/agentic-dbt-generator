# ECR Repositories for Container Images

# Orchestrator repository
resource "aws_ecr_repository" "orchestrator" {
  name                 = local.orchestrator_repo
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "AES256"
  }
  tags = merge(local.common_tags, {
    Purpose = "LangChain orchestrator container"
  })
}

resource "aws_ecr_lifecycle_policy" "orchestrator" {
  repository = aws_ecr_repository.orchestrator.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images"
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}

# dbt Runner repository
resource "aws_ecr_repository" "dbt_runner" {
  name                 = local.dbt_runner_repo
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "AES256"
  }
  tags = merge(local.common_tags, {
    Purpose = "dbt CLI runner container"
  })
}

resource "aws_ecr_lifecycle_policy" "dbt_runner" {
  repository = aws_ecr_repository.dbt_runner.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images"
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}
