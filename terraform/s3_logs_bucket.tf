resource "aws_s3_bucket" "agent_logs" {
  bucket = "${var.project_name}-${var.environment}-agent-logs"
  tags = merge(local.common_tags, {
    Purpose = "Agent execution logs organized by run"
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "agent_logs" {
  bucket = aws_s3_bucket.agent_logs.id
  rule {
    id     = "archive_old_runs"
    status = "Enabled"
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    expiration {
      days = 90
    }
  }
}