# Terraform Backend Configuration
# Store state in S3 with DynamoDB locking

terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "agentic-dbt-generator-tfstate"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "agentic-dbt-generator-state-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "agentic-dbt-generator"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
