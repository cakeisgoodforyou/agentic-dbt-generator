# Bucket for dbt projects (generated SQL, YAML files)
resource "aws_s3_bucket" "dbt_projects" {
  bucket = local.dbt_projects_bucket
  tags = merge(local.common_tags, {
    Purpose = "Store generated dbt projects"
  })
}

resource "aws_s3_bucket_versioning" "dbt_projects" {
  bucket = aws_s3_bucket.dbt_projects.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dbt_projects" {
  bucket = aws_s3_bucket.dbt_projects.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "dbt_projects" {
  bucket                  = aws_s3_bucket.dbt_projects.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}