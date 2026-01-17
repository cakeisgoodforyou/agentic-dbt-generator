import boto3

def parse_schema(env):
    glue = boto3.client("glue")
    schema = {}

    for tbl in env["source_tables"]:
        table_name = tbl["table"]

        res = glue.get_table(
            DatabaseName=env["source_database"],
            Name=table_name
        )

        schema[table_name] = {
            "columns": res["Table"]["StorageDescriptor"]["Columns"],
            "identity": {
                "primary_key": {
                    "type": "compound" if len(tbl["primary_key"]) > 1 else "single",
                    "columns": tbl["primary_key"]
                }
            },
            "semantics": tbl.get("semantics", {})
        }
        print(f"[parse-schema] Loaded schema for {table_name}")

    return schema