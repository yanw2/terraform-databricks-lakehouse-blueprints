# Use some sensible default shell settings
SHELL := /usr/bin/env bash -o pipefail
.SILENT:
.DEFAULT_GOAL := help

# Define global variables
PROJECT_ID := $(shell gcloud config get-value project)  
TFPLAN ?= databrick.tfplan
ENV ?= dev

##@ Terraform Operations 
.PHONY: init
init: ## Run terraform init
	terraform init -upgrade -reconfigure \
		-backend-config="bucket=lakehouse-blueprints-terraform-state" \
		-backend-config="prefix=$(ENV)"

.PHONY: plan
plan: ## Run terraform plan
	terraform plan -out $(TFPLAN)

.PHONY: apply
apply: ## Run terraform apply
	terraform apply $(TFPLAN) --auto-approve

.PHONY: destroy 
destroy: ## Run terraform destroy
	$(call user_confirm,Are you sure?)	
	terraform destroy

.PHONY: format
format: ## Run terraform formatter
	terraform fmt -diff -recursive
	
##@ Miscellaneous
.PHONY: help
help: ## Display help
	awk \
	  'BEGIN { \
	    FS = ":.*##"; printf "\nUsage:\n  make \033[36m[TARGET]\n" \
	  } /^[a-zA-Z0-9_.]+:.*?##/ { \
	    printf "  \033[36m%-15s\033[0m	%s\n", $$1, $$2 \
	  } /^##@/ { \
	    printf "\n\033[1m%s\033[0m\n", substr($$0, 5) \
	  }' $(MAKEFILE_LIST)

# Prompt for user confirmation
# Usage: $(call user_confirm,$message)
define user_confirm
	$(shell read -p "⚠️  $(1)? Continue (Y/N): " confirm && printf $$confirm | grep -iq "^[yY]" || exit 1)	
	$(info ==================================================================================================================================)
endef
