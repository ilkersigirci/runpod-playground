import argparse
import json
import logging
import os
import sys
import time

import requests
from dotenv import load_dotenv

logger = logging.getLogger(__name__)

endpoint_id = os.environ["RUNPOD_ENDPOINT_ID"]
URI = f"https://api.runpod.ai/v2/{endpoint_id}/run"


def run(prompt, params={}, stream=False):
    request = {
        "prompt": prompt,
        "max_new_tokens": 1800,
        "temperature": 0.3,
        "top_k": 50,
        "top_p": 0.7,
        "repetition_penalty": 1.2,
        "batch_size": 8,
        "stream": stream,
    }

    request.update(params)

    response = requests.post(
        URI,
        json=dict(input=request),
        headers={"Authorization": f"Bearer {os.environ['RUNPOD_API_KEY']}"},
    )

    if response.status_code == 200:
        data = response.json()
        task_id = data.get("id")
        return stream_output(task_id, stream=stream)


def stream_output(task_id, stream=False):
    # try:
    url = f"https://api.runpod.ai/v2/{endpoint_id}/stream/{task_id}"
    headers = {"Authorization": f"Bearer {os.environ['RUNPOD_API_KEY']}"}

    previous_output = ""

    try:
        while True:
            response = requests.get(url, headers=headers)
            if response.status_code == 200:
                data = response.json()
                if len(data["stream"]) > 0:
                    new_output = data["stream"][0]["output"]

                    if stream:
                        sys.stdout.write(new_output[len(previous_output) :])
                        sys.stdout.flush()
                    previous_output = new_output

                if data.get("status") == "COMPLETED":
                    if not stream:
                        return previous_output
                    break

            elif response.status_code >= 400:
                print(response)
            # Sleep for 0.1 seconds between each request
            time.sleep(0.1 if stream else 1)
    except Exception as e:
        print(e)
        cancel_task(task_id)


def cancel_task(task_id):
    url = f"https://api.runpod.ai/v2/{endpoint_id}/cancel/{task_id}"
    headers = {"Authorization": f"Bearer {os.environ['RUNPOD_API_KEY']}"}
    response = requests.get(url, headers=headers)
    return response


# python serverless_predict.py --params_json '{"temperature": 0.8, "max_tokens": 3000, "prompt_prefix": "USER: ", "prompt_suffix": "ASSISTANT: "}'
if __name__ == "__main__":
    load_dotenv()

    parser = argparse.ArgumentParser(description="Runpod Serverless Predict")
    parser.add_argument("prompt", type=str, help="Prompt to run")
    parser.add_argument("-s", "--stream", action="store_true", help="Stream output")
    parser.add_argument(
        "-p", "--params_json", type=str, help="JSON string of generation params"
    )

    args = parser.parse_args()
    prompt = "Say this is a test!" if not args.prompt else args.prompt
    params = json.loads(args.params_json) if args.params_json else "{}"

    start = time.time()
    logger.warning(run(prompt, params=params, stream=args.stream))
    logger.warning("Time taken: ", time.time() - start, " seconds")
