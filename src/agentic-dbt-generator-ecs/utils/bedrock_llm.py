import yaml
from langchain_aws import ChatBedrock
from langchain_core.messages import HumanMessage

def get_llm():
    cfg = yaml.safe_load(open("config/app_config.yaml"))

    llm = ChatBedrock(
        model_id=cfg["aws"]["bedrock_model"],
        region_name=cfg["aws"]["region"],
        model_kwargs={
            "temperature": cfg["runtime"]["temperature"],
            "max_tokens": cfg["runtime"]["max_tokens"]
        }
    )

    return llm


def invoke_llm(llm, prompt: str) -> str:
    """
    Minimal helper to keep chat semantics out of agent code.
    """
    response = llm.invoke(
        [HumanMessage(content=prompt)]
    )
    return response.content