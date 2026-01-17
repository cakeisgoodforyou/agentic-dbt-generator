#!/bin/bash
set -e

cd ../terraform

echo "Generating deployment scripts from Terraform outputs..."

# Get terraform outputs
ORCHESTRATOR_REPO=$(terraform output -raw orchestrator_repository_url)
PROJECT_ENV=$(terraform output -raw project_name)-$(terraform output -raw environment)
ECS_CLUSTER=$(terraform output -raw ecs_cluster_name)
TASK_DEF=$(terraform output -raw orchestrator_task_definition_arn | rev | cut -d'/' -f1 | rev | cut -d':' -f1)
SUBNETS=$(terraform output -raw vpc_subnets)
AWS_REGION=$(terraform output -raw aws_region)

TARGET_DIR="../src/agentic-dbt-generator-ecs"

# Generate deploy.sh
cat > "${TARGET_DIR}/deploy.sh" <<'EOF'
#!/bin/bash
set -e

PROJECT_ENV="PROJECT_ENV_PLACEHOLDER"
ORCHESTRATOR_REPO="ORCHESTRATOR_REPO_PLACEHOLDER"
AWS_REGION="AWS_REGION_PLACEHOLDER"

echo "Building Docker image for linux/amd64..."
docker build --platform=linux/amd64 -t ${PROJECT_ENV} .

echo "Logging into ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ORCHESTRATOR_REPO}

echo "Tagging image..."
docker tag ${PROJECT_ENV}:latest ${ORCHESTRATOR_REPO}:latest

echo "Pushing to ECR..."
docker push ${ORCHESTRATOR_REPO}:latest

echo "Deploy complete: ${ORCHESTRATOR_REPO}:latest"
EOF

# Replace placeholders in deploy.sh
sed -i.bak "s|PROJECT_ENV_PLACEHOLDER|${PROJECT_ENV}|g" "${TARGET_DIR}/deploy.sh"
sed -i.bak "s|ORCHESTRATOR_REPO_PLACEHOLDER|${ORCHESTRATOR_REPO}|g" "${TARGET_DIR}/deploy.sh"
sed -i.bak "s|AWS_REGION_PLACEHOLDER|${AWS_REGION}|g" "${TARGET_DIR}/deploy.sh"
rm "${TARGET_DIR}/deploy.sh.bak"

chmod +x "${TARGET_DIR}/deploy.sh"

# Generate run-task-template.sh
cat > "${TARGET_DIR}/run-task-template.sh" <<EOF
#!/bin/bash
set -e

# Customize these environment variables as needed
# EXISTING_PROJECT_LOCATION=""  # Uncomment and set if NEW_PROJECT=false

aws ecs run-task \\
  --cluster ${ECS_CLUSTER} \\
  --task-definition ${TASK_DEF} \\
  --launch-type FARGATE \\
  --network-configuration "awsvpcConfiguration={subnets=[${SUBNETS}],assignPublicIp=ENABLED}" \\
  --overrides '{
    "containerOverrides": [{
      "name": "orchestrator",
      "environment": [
        {"name": "PROMPT", "value": "Generate a staging and silver dbt model for incrementally loading the customers table."},
        {"name": "SOURCE_DATABASE", "value": "raw"},
        {"name": "SOURCE_TABLES", "value": "[{\"table\":\"customer_tbl\",\"primary_key\":[\"c_custkey\"]}]"},
        {"name": "TARGET_DATABASE", "value": "silver"},
        {"name": "NEW_PROJECT", "value": "true"}
      ]
    }]
  }' \\
  --region ${AWS_REGION}
EOF

chmod +x "${TARGET_DIR}/run-task-template.sh"

echo "✓ Generated: ${TARGET_DIR}/deploy.sh"
echo "✓ Generated: ${TARGET_DIR}/run-task-template.sh"
echo ""
echo "To deploy:"
echo "  cd ${TARGET_DIR}"
echo "  ./deploy.sh"
echo ""
echo "To run task:"
echo "  cd ${TARGET_DIR}"
echo "  ./run-task-template.sh"
