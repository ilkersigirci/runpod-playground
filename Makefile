# Oneshell means one can run multiple lines in a recipe in the same shell, so one doesn't have to
# chain commands together with semicolon
.ONESHELL:
SHELL=/bin/bash

LIBRARY_BASE_PATH=/workspace/runpod-playground

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

install-rye:
	! command -v rye &> /dev/null && curl -sSf https://rye-up.com/get | bash
	# echo 'source "$HOME/.rye/env"' >> ~/.bashrc && rye config --set-bool behavior.use-uv=true

install: ## Installs the development version of the package
	$(MAKE) install-rye
	rye sync --no-lock

start-vllm:
	nohup bash $LIBRARY_BASE_PATH/scripts/start_vllm.sh > vllm_log.txt 2>&1 &

download-model:
	python download_model.py