#!make
# base makefile for nodejs
SHELL = /bin/bash
# Generate env
ENV_FILE=*.env
ENVS=$(basename $(wildcard *.env))
PROD=false

# package
PKG_MANAGER?=yarn
PKG_MANAGER_I?=$(PKG_MANAGER) install
ifeq ($(PKG_MANAGER), yarn)
PROD_I:= --production=true
else
PROD_I:= --save-prod
endif

# deploy
REMOTE_DIR_DEPLOY:=/var/www

# func to generate inline args from file
line=$(shell cat $(1) | while read line; do echo -n "$$line "; done)

# node js (may change)
NODE_PATH?=src
APP?=$(NODE_PATH)/app.js
NODE_MODULES=node_modules
prod-exe?=node
EXTS:= .pug,.ts,.vue,.js
dev-exe?=nodemon -e $(EXTS)

.DEFAULT_GOAL := help
.PHONY: $(NODE_ENVS)
.PRECIOUS: %.run
$(ENVS): % : %.run

help:
	@echo "[======== Node Help ========]"
	@echo "Usage: make <env> (ARG=<your-arg>)"
	@echo "Available environments: $(ENVS)"
	@$(MAKE) help_more || true

# run node js server
%.run:
	@echo [ === Building $* environments === ]
	$(eval ENVS=$(call line, $*.env))
	NODE_PATH=$(NODE_PATH) $(ENVS) \
	  $($*-exe) $(OPTIONS) \
	  -r esm $(APP) 

# define requirements per envs
prod.install:
	$(PKG_MANAGER_I) $(PROD_I)

dev.install:
	$(PKG_MANAGER_I) --save
	$(PKG_MANAGER_I) global nodemon

deploy: 
	ssh $(USER_DEPLOY)@$(SSH_ADDRESS) "cd $(REMOTE_DIR_DEPLOY);\
	/bin/bash -c '\
	git fetch --all && git reset --hard upstream/master;\
	PKG_MANAGER=npm make prod.install'"

clear:
	rm -rf *.log