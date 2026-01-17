from workflows.parse_glue_schema     import parse_schema
from workflows.load_existing_project import load_project
from agents.planning_agent           import run_planning_agent
from agents.generation_agent         import run_generation_agent
from agents.refining_agent           import run_refining_agent

def run_workflow(env):
    print("[workflow] Parsing Glue schema")
    schema = parse_schema(env)

    existing_project = None
    if not env["new_project"]:
        print("[workflow] Loading existing dbt project")
        existing_project = load_project(env)

    print("[workflow] Running planning agent")
    plan = run_planning_agent(env, schema, existing_project)

    print("[workflow] Running generation agent")
    proposal = run_generation_agent(env, schema, plan)

    print("[workflow] Running refining agent")
    run_refining_agent(env, schema, proposal)