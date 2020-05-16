# Base makefile for ansible / vagrant projects
SHELL = /bin/bash
# read setting from config
config = $(shell yq r .manala.yaml $(1))
# All variables necessary to run and debug ansible playbooks
PLAYBOOKS=$(basename $(wildcard *.yml))
IP?=$(call config,vagrant.network.ip)
DOMAIN?=$(call config,vagrant.domain)
# ansible vars
BASHED_YAML:=$(shell echo -n $(call config,vagrant.ansible.vars) | sed -e 's/:[^:\/\/]/="/g;s/$$/"/g;s/ *=/=/g')
OPTIONS:= $(foreach var, $(BASHED_YAML), -e $(subst ",,$(var)))
# Environment variables of ansible 
ANSIBLE_STDOUT_CALLBACK:=default
# Default Inventory
INVENTORY?= $(call config,ansible.default_inventory)
playbook_exe= \
	ANSIBLE_STDOUT_CALLBACK=$(ANSIBLE_STDOUT_CALLBACK) \
	ansible-playbook $(OPTIONS) \
	-i $(INVENTORY) $*.yml $(ARG)
# Prompt exe
prompt?=echo -ne "\x1b[33m $(1) Sure ? [y/N]\x1b[m" && read ans && [ $${ans:-N} = y ]

help:
	@echo "[======== Ansible Help ========]"
	@echo "Usage: make <playbook> (ARG=<your-arg>)"
	@echo "Available PLAYBOOKS: $(PLAYBOOKS)"
	@$(MAKE) help_more || true
	@echo "[========== OPTIONS ===========]"
	@echo "$(BASHED_YAML)"
	@echo "Ip: $(IP)"
	@echo "Domain: $(DOMAIN)"
	@echo "default inventory: $(INVENTORY)"
	@echo "[==============================]"

.DEFAULT_GOAL := help
.PHONY: $(PLAYBOOKS)
.PRECIOUS: %.run
$(PLAYBOOKS): % : %.run

install:
	ansible-galaxy install -r roles/requirements.yml $(ARG)
	$(foreach var,$(shell ls -d *roles/role*/requirements.txt),pip install -r $(var);)
	$(foreach var,$(shell ls -d *.ext_roles/role*/requirements.txt),pip install -r $(var);)

# ==============================
# Warning run target is for prod
# ==============================
%.run: running
	@$(call prompt)
	@$(call playbook_exe)

# avoid prompt (Use this in automated processes)
%.run-f: running
	@$(call playbook_exe)

running:
	@echo "RUNNING $(DEBUG): \n"${playbook_exe}

# =============================
# Debugging zone on next lines
# =============================
OPTIONS+=\
	-e ansible_host=$(DOMAIN)\
	-e ansible_port=22\
	-e ansible_user=vagrant\

debug: 
	$(eval ANSIBLE_STDOUT_CALLBACK:=yaml)
	@$(MAKE) running DEBUG='IN DEBUG MODE '

test-yaml:
	@echo $(OPTIONS)