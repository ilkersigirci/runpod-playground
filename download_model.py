"""
pip install python-dotenv huggingface_hub

HF_HOME=/workspace/huggingface python download_model.py
"""

import os

from dotenv import load_dotenv
from huggingface_hub import snapshot_download


def main():
    repo_id = "mistralai/Mixtral-8x7B-Instruct-v0.1"
    # repo_id = "NousResearch/Nous-Hermes-2-Mixtral-8x7B-DPO"
    # repo_id = "turboderp/Mixtral-8x7B-instruct-exl2"
    # repo_id = "turboderp/TinyLlama-1B-exl2"
    # repo_id = "CohereForAI/aya-101"
    # repo_id = "wolfram/miquliz-120b-v2.0-5.0bpw-h6-exl2"
    # repo_id = "Trendyol/Trendyol-LLM-7b-base-v0.1"
    # repo_id = "teknium/OpenHermes-2.5-Mistral-7B"
    # repo_id = "sambanovasystems/SambaLingo-Turkish-Chat"

    local_dir_name = repo_id.split("/")[1]

    token = os.getenv("HF_TOKEN", None)

    # hf_hub_download(repo_id=repo_id, filename="config.json", revision="8.0bpw")

    # NOTE: First downloads to cache and then copies to local_dir
    snapshot_download(
        repo_id=repo_id,
        revision="main",
        local_dir=f"./models/{local_dir_name}",
        local_dir_use_symlinks=False,
        # ignore_patterns=["*.pt"],
        ignore_patterns=["*.pt", "*.bin"],
        token=token,
    )


if __name__ == "__main__":
    load_dotenv()

    main()
