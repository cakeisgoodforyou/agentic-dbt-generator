# Athena Workgroup for dbt Agent Queries

resource "aws_athena_workgroup" "dbt_agent" {
  name = local.athena_workgroup

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      # Direct reference to S3 bucket
      output_location = "s3://${aws_s3_bucket.athena_results.id}/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
    engine_version {
      selected_engine_version = "Athena engine version 3"
    }
  }
  tags = local.common_tags
}
