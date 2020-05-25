# Deno config
ENTRY_DIR:=src
ENTRY:=app.ts
IMPORT_MAP:=import-map.json
# Argument group for different usages
ARGS:=\
	  --allow-env\
	  --allow-read\

NET:=$(ARGS)\
	  --allow-net\
	  --recompile

FULL:=$(ARGS) $(NET)\
	  --importmap=$(ENTRY_DIR)/$(IMPORT_MAP)\
	  --allow-hrtime\
	  --unstable\
	  --config=tsconfig.json

BIN:=$(ENTRY_DIR)/bin

# Deployment (override this in Makefile)
REMOTE_DIR_DEPLOY:=/var/www
SSH_ADDRESS:=site.test
USER_DEPLOY:=root

.DEFAULT_GOAL := help
.PRECIOUS: start debug

help:
	@echo "[======== Deno Help ========]"
	@echo "Usage: make start | debug"
	@$(MAKE) help_more || true

# Run server
start:
	deno run $(NET) $(ENTRY_DIR)/$(ENTRY)

full:
	deno run $(FULL) $(ENTRY_DIR)/$(ENTRY)

lint:
	deno fmt

# Start with debugger
debug:
	$(eval ARGS+=--debug)
	$(MAKE) start
	@echo 'Started in Debug mode : '
	@echo 'Open chrome://inspect/#devices'

deploy:
	ssh $(USER_DEPLOY)@$(SSH_ADDRESS) "cd $(REMOTE_DIR_DEPLOY);\
	/bin/bash -c '\
	git fetch --all && git reset --hard upstream/master;'"

clear:
	rm -rf *.log
