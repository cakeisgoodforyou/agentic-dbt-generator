# Core Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name (used in resource naming)"
  type        = string
  default     = "agentic-dbt-gen"
}

# ECS Configuration
variable "orchestrator_cpu" {
  description = "CPU units for orchestrator (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 1024
}

variable "orchestrator_memory" {
  description = "Memory for orchestrator in MB (512, 1024, 2048, 4096, 8192)"
  type        = number
  default     = 2048
}

variable "dbt_runner_cpu" {
  description = "CPU units for dbt runner"
  type        = number
  default     = 512
}

variable "dbt_runner_memory" {
  description = "Memory for dbt runner in MB"
  type        = number
  default     = 1024
}

# Glue Configuration
variable "source_databases" {
  description = "List of Glue databases to analyze"
  type        = list(string)
  default     = ["raw"]
}

# Tags
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
