# Static ———————————————————————————————————————————————————————————————————————————————————————————————————————————————
.DEFAULT_GOAL := help
PROJECT_NAME=$(shell basename $$(pwd) | tr '[:upper:]' '[:lower:]')
PHP_USER=utente
RR_IMAGE=roadrunner-skeleton
WORKDIR=/app
PROJECT_TOOL=$(WORKDIR)/tools/bin/project/project
PROJECT_TOOL_RELATIVE=./tools/bin/project/project

# Docker conf ——————————————————————————————————————————————————————————————————————————————————————————————————————————
ifeq ($(wildcard ./docker/docker-compose.override.yml),)
	COMPOSE_OVERRIDE=
else
	COMPOSE_OVERRIDE=-f ./docker/docker-compose.override.yml
endif

COMPOSE=docker compose --env-file .env --file ./docker/docker-compose.yml $(COMPOSE_OVERRIDE) -p $(PROJECT_NAME)

COMPOSE_RUN=$(COMPOSE) run -u $(PHP_USER) --rm

COMPOSE_EXEC=$(COMPOSE) exec -u $(PHP_USER)
COMPOSE_EXEC_RR=$(COMPOSE_EXEC) $(RR_IMAGE)
COMPOSE_EXEC_RR_NO_PSEUSO_TTY=$(COMPOSE_EXEC) -T $(RR_IMAGE)

# RoadRunner commands --------------------------------------------------------------------------------------------------
.PHONY: build
build: ## Build RoadRunner image
	$(COMPOSE) build --no-cache


.PHONY: setup
setup: ## RoadRunner setup
	$(COMPOSE) build
	$(COMPOSE_RUN) $(RR_IMAGE) bash -c "composer install"
	cp -n .env.example .env
	echo "Initialization completed!"

.PHONY: rr
rr: ## Executes RoadRunner command
	$(COMPOSE_EXEC_RR) rr -c /etc/rr.yaml "$$ARG"

.PHONY: rr-reset
rr-reset: ## Manual restarting RoadRunner
	$(COMPOSE_EXEC_RR) rr -c /etc/rr.yaml reset

.PHONY: rr-workers
rr-workers: ## Shows RoadRunner rr workers list
	$(COMPOSE_EXEC_RR) rr -c /etc/rr.yaml workers

# Docker commands ——————————————————————————————————————————————————————————————————————————————————————————————————————
.PHONY: up
up: ## Containers up
	$(COMPOSE) up $$ARG

.PHONY: upd
upd: ## Containers up - daemon mode
	$(COMPOSE) up -d $$ARG

.PHONY: down
down: ## Containers down
	$(COMPOSE) down $$ARG

.PHONY: enter
enter: ## User access to the RoadRunner container
	$(COMPOSE_EXEC_RR) /bin/zsh

.PHONY: enter-root
enter-root: ## Root access to the RoadRunner container
	$(COMPOSE) exec -u root $(PHP_IMAGE) /bin/bash

.PHONY: purge
purge: ## Containers down, cleans images and volumes.
	$(COMPOSE) down --rmi=all --volumes --remove-orphans

.PHONY: log
log: ## Docker logs
	$(COMPOSE) logs -f

.PHONY: ps
ps: ## Container list
	@$(COMPOSE) ps

.PHONY: compose
compose: ## Docker compose wrapper
	@$(COMPOSE) "$$ARG"

.PHONY: run
run: ## Executes commands inside RoadRunner container
	$(COMPOSE_RUN) $(RR_IMAGE) bash -c "$$ARG"

# CS Fixer commands ————————————————————————————————————————————————————————————————————————————————————————————————————

.PHONY: coding-standard-fix
coding-standard-fix: ## Code style fix. No params = format all files. E.g. make coding-standard-fix ARG="./file.php"
	$(COMPOSE_EXEC_RR) $(PROJECT_TOOL) coding-standard-fix $$ARG

.PHONY: coding-standard-check-staged
coding-standard-check-staged: ## Code style check only staged files
	$(COMPOSE_EXEC_RR_NO_PSEUSO_TTY) $(PROJECT_TOOL) coding-standard-check-staged

.PHONY: coding-standard-fix-staged
coding-standard-fix-staged: ## Code style fix only staged files
	$(COMPOSE_EXEC_RR_NO_PSEUSO_TTY) $(PROJECT_TOOL) coding-standard-fix-staged

# Commitlint commands ——————————————————————————————————————————————————————————————————————————————————————————————————

.PHONY: conventional
conventional: ## chiama conventional commit per validare l'ultimo commit message
	$(COMPOSE_RUN) -T $(NODEJS_IMAGE) commitlint -e --from=HEAD -V

# PHP commands —————————————————————————————————————————————————————————————————————————————————————————————————————————

.PHONY: composer
composer: ## PHP composer wrapper. E.g. make composer ARG=update
	$(COMPOSE_EXEC_RR) composer "$$ARG"

# Project autopilot command ————————————————————————————————————————————————————————————————————————————————————————————

.PHONY: project
project: ## Project autopilot wrapper inside the RoadRunner container. Use make project ARG=shortlist for the help
	if [ ! -f ${PROJECT_TOOL_RELATIVE} ]; then \
		$(COMPOSE_RUN) $(RR_IMAGE) bash -c "composer install" \
    fi; \
	$(COMPOSE_EXEC_RR_NO_PSEUSO_TTY) $(PROJECT_TOOL) "$$ARG"

.PHONY: help
help:	## Show this help
	@grep -hE '^[A-Za-z0-9_ \-]*?:.*##.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'