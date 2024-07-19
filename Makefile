# Oneshell means one can run multiple lines in a recipe in the same shell, so one doesn't have to
# chain commands together with semicolon
.ONESHELL:
SHELL=/bin/bash

LIBRARY_BASE_PATH=/workspace/runpod-playground
PYTHON=python
DEPLOYED_MODEL_NAME=alpindale/WizardLM-2-8x22B
MAX_CONTEXT_LEN=32000

.PHONY: help install
.DEFAULT_GOAL=help

help:
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
		 awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m\
		 %s\n", $$1, $$2}'

# If .env file exists, include it and export its variables
ifeq ($(shell test -f .env && echo 1),1)
    include .env
    export
endif

python-info: ## List information about the python environment
	@which ${PYTHON}
	@${PYTHON} --version

update-pip:
	${PYTHON} -m pip install -U pip

install-rye: ## Install rye
	! command -v rye &> /dev/null && curl -sSf https://rye-up.com/get | bash
	# echo 'source "$HOME/.rye/env"' >> ~/.bashrc && rye config --set-bool behavior.use-uv=true

install: ## Installs the development version of the package
	$(MAKE) install-rye
	rye sync --no-lock

change-model-env: ## Change the model that is specified in the .env file
	# sed -i 's/DEPLOYED_MODEL_NAME=alpindale\/WizardLM-2-8x22B/DEPLOYED_MODEL_NAME=CohereForAI\/c4ai-command-r-v01/g' .env
	sed -i '/DEPLOYED_MODEL_NAME=/d' .env
	echo "DEPLOYED_MODEL_NAME=${DEPLOYED_MODEL_NAME}" >> .env

change-max-context-len-env: ## Change the max context length that is specified in the .env file
	# sed -i 's/MAX_CONTEXT_LEN=32000/MAX_CONTEXT_LEN=40000/g' .env
	sed -i '/MAX_CONTEXT_LEN=/d' .env
	echo "MAX_CONTEXT_LEN=${MAX_CONTEXT_LEN}" >> .env

download-model: ## Download the model that is specified in the .env file
	nohup bash ${LIBRARY_BASE_PATH}/scripts/download_model.sh > download_model_log.txt 2>&1 &

start-vllm: ## Start the VLLM server
	nohup bash ${LIBRARY_BASE_PATH}/scripts/start_vllm.sh > vllm_log.txt 2>&1 &
	nohup bash ${LIBRARY_BASE_PATH}/scripts/run_preodically_basic.sh ${LIBRARY_BASE_PATH}/scripts/healthcheck_model_api.sh > healthcheck_periodically.txt 300 2>&1 &

stop-vllm: ## Stop the VLLM server
	pkill -f 'run_preodically_basic|vllm.entrypoints'

restart-vllm: ## Stops and starts the VLLM server
	$(MAKE) stop-vllm
	$(MAKE) start-vllm

log-vllm: ## Show the log of the VLLM server
	tail -f vllm_log.txt