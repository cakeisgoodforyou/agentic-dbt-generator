import os
import json

REQUIRED_VARS = [
    "PROMPT",
    "SOURCE_DATABASE",
    "SOURCE_TABLES",
    "TARGET_DATABASE",
    "NEW_PROJECT"
]

def load_env():
    env = {}
    
    for var in REQUIRED_VARS:
        if var not in os.environ:
            raise ValueError(f"Missing required env var: {var}")
        env[var.lower()] = os.environ[var]
    
    env["source_tables"]             = json.loads(env["source_tables"])
    env["new_project"]               = env["new_project"].lower() == "true"
    env["existing_project_location"] = os.environ.get("EXISTING_PROJECT_LOCATION")
    if not env["new_project"] and not env["existing_project_location"]:
        raise ValueError("existing_project_location required if new_project=false")
    
    return env