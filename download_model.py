"""
pip install python-dotenv huggingface_hub

HF_HOME=/workspace/runpod-playground/huggingface python download_model.py
"""

import os

from dotenv import load_dotenv
from huggingface_hub import snapshot_download


def download_model_hf(
    repo_id: str = "mistralai/Mixtral-8x7B-Instruct-v0.1",
    revision: str = "main",
    ignore_patterns: list[str] | None = None,
) -> None:
    local_dir_name = repo_id.split("/")[1]

    if ignore_patterns is None:
        ignore_patterns = ["*.pt"]

    token = os.getenv("HF_TOKEN", None)

    # NOTE: First downloads to cache and then copies to local_dir
    snapshot_download(
        repo_id=repo_id,
        revision=revision,
        local_dir=f"/workspace/runpod-playground/models/{local_dir_name}",
        local_dir_use_symlinks=False,
        ignore_patterns=ignore_patterns,
        token=token,
    )


if __name__ == "__main__":
    load_dotenv()

    repo_id = "mistralai/Mixtral-8x7B-Instruct-v0.1"
    # repo_id = "NousResearch/Nous-Hermes-2-Mixtral-8x7B-DPO"
    # repo_id = "turboderp/Mixtral-8x7B-instruct-exl2"
    # repo_id = "turboderp/TinyLlama-1B-exl2"
    # repo_id = "CohereForAI/aya-101"
    # repo_id = "CohereForAI/c4ai-command-r-plus"
    # repo_id = "wolfram/miquliz-120b-v2.0-5.0bpw-h6-exl2"
    # repo_id = "Trendyol/Trendyol-LLM-7b-base-v0.1"
    # repo_id = "teknium/OpenHermes-2.5-Mistral-7B"
    # repo_id = "sambanovasystems/SambaLingo-Turkish-Chat"

    revision = "main"
    # revision = "6.0bpw"

    # ignore_patterns = ["*.pt"]
    ignore_patterns = ["*.pt", "*.bin"]

    download_model_hf(
        repo_id=repo_id, revision=revision, ignore_patterns=ignore_patterns
    )
