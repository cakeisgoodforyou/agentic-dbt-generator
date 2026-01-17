import yaml
from utils.bedrock_llm import get_llm
from utils.bedrock_llm import invoke_llm
from utils.s3_logger import log_to_s3

def run_planning_agent(env, schema, existing_project):
    instructions = yaml.safe_load(open("config/planning_agent.yaml"))
    llm = get_llm()

    prompt = f"""
{instructions['system']}

User prompt:
{env['prompt']}

Schema:
{schema}

Existing project:
{existing_project}
"""

    plan = invoke_llm(llm, prompt)

    log_to_s3("planning/plan.txt", plan)

    print("[planning-agent] Plan generated (human review placeholder)")
    return plan