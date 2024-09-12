import os

from dotenv import load_dotenv
from huggingface_hub import snapshot_download


def download_model_hf(
    repo_id: str = "alpindale/c4ai-command-r-plus-GPTQ",
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
        ignore_patterns=ignore_patterns,
        token=token,
    )


if __name__ == "__main__":
    load_dotenv()

    DEPLOYED_MODEL_NAME = os.getenv("DEPLOYED_MODEL_NAME", "alpindale/WizardLM-2-8x22B")
    revision = "main"
    # revision = "6.0bpw"

    # ignore_patterns = ["*.pt"]
    ignore_patterns = ["*.pt", "*.bin"]

    download_model_hf(
        repo_id=DEPLOYED_MODEL_NAME, revision=revision, ignore_patterns=ignore_patterns
    )
