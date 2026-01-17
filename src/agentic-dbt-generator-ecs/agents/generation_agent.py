import yaml
from utils.bedrock_llm import get_llm
from utils.bedrock_llm import invoke_llm
from utils.s3_logger import log_to_s3

def run_generation_agent(env, schema, plan):
    instructions = yaml.safe_load(open("config/generation_agent.yaml"))
    llm = get_llm()

    prompt = f"""
{instructions['system']}

Plan:
{plan}

Schema:
{schema}
"""

    #output = llm(prompt)
    output = invoke_llm(llm, prompt)

    log_to_s3("generation/dbt_output.txt", output)

    print("[generation-agent] DBT code generated (executor placeholder)")
    return output