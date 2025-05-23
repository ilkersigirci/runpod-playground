# Oneshell means one can run multiple lines in a recipe in the same shell, so one doesn't have to
# chain commands together with semicolon
.ONESHELL:
SHELL=/bin/bash

PYTHON=python

.PHONY: help install gui
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

change-paths-in-env-file: ## Change the path in the .env file with the current working directory
	@CWD=$$(pwd)
	sed -i "s|DUMMY_PATH|$$CWD|g" .env

prepare-env-file:  ## Copy .env.example to .env and correct the paths
	cp .env.example .env
	$(MAKE) change-paths-in-env-file

replace-value-in-env-file: ## Replace a variable in the .env file
	@if [ -z "${variable_name}" ] || [ -z "${new_value}" ]; then \
		echo "Usage: make replace-value-in-env-file variable_name=<variable> new_value=<value>"; \
		exit 1; \
	fi
	sed -i "s|${variable_name}=.*|${variable_name}=${new_value}|g" .env

install-uv:
	! command -v uv &> /dev/null && curl -LsSf https://astral.sh/uv/install.sh | sh
	# echo '. "$$HOME/.local/bin/env"' >> ~/.bashrc

install-package: ## Installs the development version of the package
	$(MAKE) install-uv
	uv sync --frozen

initial-runpod-install: ## Install necessary tools and packages for Runpod, also install project dependencies
	nohup bash ./scripts/initial_install.sh > initial_runpod_install_$(shell date +%Y%m%d_%H%M%S).txt 2>&1 &

download-model: ## Download the model that is specified in the .env file
	nohup bash ./scripts/download_model.sh > download_model_log_$(shell date +%Y%m%d_%H%M%S).txt 2>&1 &

start-vllm: ## Start the VLLM server
	nohup bash ./scripts/start_vllm.sh > vllm_log_$(shell date +%Y%m%d_%H%M%S).txt 2>&1 &
	nohup bash ./scripts/run_preodically_basic.sh ./scripts/healthcheck_model_api.sh > healthcheck_periodically_$(shell date +%Y%m%d_%H%M%S).txt 2>&1 &

stop-vllm: ## Stop the VLLM server
	pgrep -f 'run_preodically_basic|vllm' | xargs -r kill -9
	# pkill -f 'run_preodically_basic|vllm'

restart-vllm: ## Stops and starts the VLLM server
	$(MAKE) stop-vllm
	$(MAKE) start-vllm

log-vllm: ## Show the log of the VLLM server, only the last log file
	@last_log_file=$(shell ls -t vllm_log_*.txt | head -n 1); \
	tail -f -n 100 $$last_log_file

send-chat-message: ## Send a chat message to the VLLM server
	bash ./scripts/send_api_chat_message.sh send_message_with_system

gui: ## Start the GUI
	source $$HOME/.local/bin/env bash

	nohup uv run streamlit run \
		--server.address 0.0.0.0 \
		--server.port 5000 \
		--server.enableCORS=false \
		--server.enableXsrfProtection=false \
		runpod_playground/gui/main.py > streamlit_log_$(shell date +%Y%m%d_%H%M%S).txt 2>&1 &
