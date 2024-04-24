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

    DEPLOYED_MODEL_NAME = os.getenv("DEPLOYED_MODEL_NAME", "alpindale/WizardLM-2-8x22B")

    # DEPLOYED_MODEL_NAME = "mistralai/Mixtral-8x22B-Instruct-v0.1"
    # DEPLOYED_MODEL_NAME = "alpindale/WizardLM-2-8x22B"
    # DEPLOYED_MODEL_NAME = "turboderp/TinyLlama-1B-exl2"
    # DEPLOYED_MODEL_NAME = "CohereForAI/c4ai-command-r-plus"
    # DEPLOYED_MODEL_NAME = "Trendyol/Trendyol-LLM-7b-base-v0.1"
    # DEPLOYED_MODEL_NAME = "sambanovasystems/SambaLingo-Turkish-Chat"
    # DEPLOYED_MODEL_NAME = "microsoft/Phi-3-mini-128k-instruct"

    revision = "main"
    # revision = "6.0bpw"

    # ignore_patterns = ["*.pt"]
    ignore_patterns = ["*.pt", "*.bin"]

    download_model_hf(
        repo_id=DEPLOYED_MODEL_NAME, revision=revision, ignore_patterns=ignore_patterns
    )
