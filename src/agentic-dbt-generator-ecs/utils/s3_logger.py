import boto3
import uuid
import yaml
from datetime import datetime

cfg = yaml.safe_load(open("config/app_config.yaml"))
s3 = boto3.client("s3")
run_id = datetime.utcnow().strftime('run_%Y%m%d_%H%M%S')
#str(uuid.uuid4())

def log_to_s3(path, content):
    key = f"{cfg['logging']['prefix']}{run_id}/{path}"
    s3.put_object(
        Bucket=cfg["logging"]["s3_bucket"],
        Key=key,
        Body=content.encode("utf-8")
    )