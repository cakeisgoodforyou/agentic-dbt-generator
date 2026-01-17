# Agentic DBT Generator

AI-powered DBT model generation using AWS Bedrock and ECS.

## Overview

This project uses LLM agents to automatically generate DBT models from AWS Glue catalog schemas. It creates production-ready DBT SQL with proper incremental logic that handles both inserts and updates.

## Quick Start

### 1. Prerequisites

- AWS CLI configured
- Terraform installed
- Docker installed
- TPC-H data in S3 (or your own data source)
- AWS Glue catalog configured

### 2. Deploy Infrastructure

```bash
cd terraform
terraform init
terraform apply
```

### 3. Generate Deployment Scripts

```bash
cd scripts
./generate_scripts.sh
```

This creates:
- `src/agentic-dbt-generator-ecs/deploy.sh`
- `src/agentic-dbt-generator-ecs/run-task-template.sh`

### 4. Build and Deploy Container

```bash
cd ../src/agentic-dbt-generator-ecs
./deploy.sh
```

### 5. Run Generator

```bash
./run-task-template.sh
```

## Configuration

### App Config (`src/agentic-dbt-generator-ecs/config/app_config.yaml`)

```yaml
aws:
  region: us-east-1
  bedrock_model: global.anthropic.claude-haiku-4-5-20251001-v1:0

runtime:
  max_tokens: 5000
  temperature: 0.2

logging:
  s3_bucket: agentic-dbt-gen-dev-agent-logs
  prefix: runs/
```

### Task Parameters (edit `run-task-template.sh`)

- `PROMPT` - Description of what to generate
- `SOURCE_DATABASE` - Glue database name
- `SOURCE_TABLES` - JSON array of tables with primary keys
- `TARGET_DATABASE` - Target schema name
- `NEW_PROJECT` - `true` for new project, `false` to update existing
- `EXISTING_PROJECT_LOCATION` - S3 URI (required if NEW_PROJECT=false)

## Output

Each run creates a timestamped folder in S3:

```
s3://agent-logs-bucket/runs/run_YYYYMMDD_HHMMSS/
├── planning.json          # Planning agent output
├── generation.json        # Generation agent output
├── refining.json          # Refining agent output
└── dbt_project/          # Complete DBT project
    ├── dbt_project.yml
    └── models/
        ├── staging/
        │   └── stg_*.sql
        ├── sources.yml
        └── schema.yml
```

## Project Structure

```
.
├── terraform/              # Infrastructure as code
├── scripts/               # Helper scripts
│   └── generate_scripts.sh
└── src/
    └── agentic-dbt-generator-ecs/
        ├── agents/        # LLM agent implementations
        ├── workflows/     # Orchestration logic
        ├── utils/         # Helper utilities
        ├── config/        # Agent configurations
        └── main.py        # Entry point
```

## Example Generated SQL

```sql
{{
  config(
    materialized='incremental',
    unique_key='c_custkey',
    incremental_strategy='merge'
  )
}}

SELECT
  c_custkey,
  c_name,
  c_address,
  c_nationkey,
  c_phone,
  c_acctbal,
  c_mktsegment,
  c_comment,
  CURRENT_TIMESTAMP() AS dbt_loaded_at
FROM {{ source('raw', 'customer_tbl') }} src

{% if is_incremental() %}
  WHERE src.c_custkey IN (
    SELECT s.c_custkey
    FROM {{ source('raw', 'customer_tbl') }} s
    LEFT JOIN {{ this }} tgt ON s.c_custkey = tgt.c_custkey
    WHERE tgt.c_custkey IS NULL
       OR s.c_name != tgt.c_name
       OR s.c_address != tgt.c_address
       OR s.c_phone != tgt.c_phone
       OR s.c_acctbal != tgt.c_acctbal
  )
{% endif %}
```

## Development

- Agent instructions: `config/*.yaml`
- Core workflow: `workflows/dbt_generator_workflow.py`
- Agents: `agents/*_agent.py`

## Troubleshooting

**Container won't build:**
- Check Docker is running
- Verify AWS credentials

**Task fails to start:**
- Check ECS cluster exists
- Verify task definition is registered
- Check VPC/subnet configuration

**No output generated:**
- Check CloudWatch logs for the ECS task
- Verify S3 bucket permissions
- Check Bedrock model access

## License

MIT