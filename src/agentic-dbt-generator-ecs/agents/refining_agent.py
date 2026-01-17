import yaml
from utils.bedrock_llm import get_llm
from utils.bedrock_llm import invoke_llm
from utils.s3_logger import log_to_s3

def run_refining_agent(env, schema, proposal):
    instructions = yaml.safe_load(open("config/refining_agent.yaml"))
    llm = get_llm()

    prompt = f"""
{instructions['system']}

proposal:
{proposal}

Schema:
{schema}
"""

    #output = llm(prompt)
    output = invoke_llm(llm, prompt)

    log_to_s3("refining/refined_dbt_output.txt", output)

    print("[refining-agent] DBT code refined (executor placeholder)")