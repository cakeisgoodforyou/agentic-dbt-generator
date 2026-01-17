import boto3

def load_project(env):
    s3 = boto3.client("s3")

    bucket, prefix = env["existing_project_location"] \
        .replace("s3://", "") \
        .split("/", 1)

    if not prefix.endswith("/"):
        prefix += "/"

    files = {}

    paginator = s3.get_paginator("list_objects_v2")
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for obj in page.get("Contents", []):
            key = obj["Key"]

            if key.endswith("/"):
                continue

            body = s3.get_object(Bucket=bucket, Key=key)["Body"] \
                     .read() \
                     .decode("utf-8")

            relative_path = key.replace(prefix, "")
            files[relative_path] = body

    print(f"[load-project] Loaded {len(files)} files from existing dbt project")
    return files