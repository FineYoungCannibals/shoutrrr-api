from fastapi import FastAPI, Form, Header, HTTPException
import subprocess

from helpers import combine_env_configs

env_config = combine_env_configs()

app = FastAPI()

API_KEY = env_config["API_KEY"]
SLACK_BOT_TOKEN = env_config["SLACK_BOT_TOKEN"]


@app.post("/notify")
async def send_notification(
    message: str = Form(...),
    channel: str = Form(...),
    x_api_key: str = Header(None)
):
    if API_KEY and x_api_key != API_KEY:
        raise HTTPException(status_code=403, detail="Invalid API key")

    # Construct the Shoutrrr URL with the Slack channel
    shoutrrr_url = f"slack://{SLACK_BOT_TOKEN}@{channel}"

    # Execute the Shoutrrr command
    try:
        subprocess.run(["shoutrrr", "send", "-u", shoutrrr_url, "-m", message], check=True)
        return {"status": "success", "channel": channel, "message": message}
    except subprocess.CalledProcessError:
        return {"status": "error", "message": "Failed to send notification"}
