
# Glue Database for Raw Data
resource "aws_glue_catalog_database" "raw" {
  name        = "raw"
  description = "Raw TPC-H data for dbt agent project"

  tags = local.common_tags
}

# IAM Role for Glue Crawler
# Trust policy - allow Glue service to assume this role
data "aws_iam_policy_document" "glue_crawler_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "glue_crawler" {
  name               = "${var.project_name}-${var.environment}-glue-crawler"
  assume_role_policy = data.aws_iam_policy_document.glue_crawler_trust.json
  tags = local.common_tags
}

# Attach AWS managed Glue service role
resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_crawler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Custom policy for accessing public TPC-H data
data "aws_iam_policy_document" "glue_s3_public" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::redshift-downloads",
      "arn:aws:s3:::redshift-downloads/*"
    ]
  }

  # Also allow access to dbt projects bucket (for output)
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.dbt_projects.arn,
      "${aws_s3_bucket.dbt_projects.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "glue_s3_public" {
  name   = "s3-access"
  role   = aws_iam_role.glue_crawler.id
  policy = data.aws_iam_policy_document.glue_s3_public.json
}


# Glue Crawler for TPC-H Data
resource "aws_glue_crawler" "tpch" {
  database_name = aws_glue_catalog_database.raw.name
  name          = "${var.project_name}-${var.environment}-tpch-crawler"
  role          = aws_iam_role.glue_crawler.arn
  description   = "Crawler for TPC-H benchmark dataset (10GB)"
  s3_target {
    # AWS public TPC-H data (10GB size)
    path = "s3://redshift-downloads/TPC-H/2.18/10GB/"
  }
  # Crawler configuration
  configuration = jsonencode({
    Version = 1.0
    CrawlerOutput = {
      Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
    }
  })
  # Don't run on schedule - Only need to run once manually.
  schedule = null
  # Crawler behavior
  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "LOG"
  }
  tags = local.common_tags
}
