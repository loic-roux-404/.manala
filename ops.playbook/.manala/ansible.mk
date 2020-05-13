# Base makefile for ansible / vagrant projects
SHELL = /bin/bash
# read setting from config
CONFIG=config.json
config = $(shell yq r config.yaml $(1) || false)
# All variables necessary to run and debug ansible playbooks
PLAYBOOKS=$(basename $(wildcard *.yml))
IP?=$(call config,network.ip)
DOMAIN?=$(call config,domain)
# ansible vars
keyboard_mac?=$(call config,ansible.vars.keyboard_mac)
# ansible-playbook arguments
OPTIONS:= -e keyboard_mac=$(keyboard_mac)
# Environment variables of ansible 
ANSIBLE_STDOUT_CALLBACK:=default
# Default Inventory
INVENTORY?= $(call config,ansible.inventory)
playbook_exe= \
	ANSIBLE_STDOUT_CALLBACK=$(ANSIBLE_STDOUT_CALLBACK) \
	ansible-playbook $(OPTIONS) \
	-i ./inventories/$(INVENTORY) $*.yml $(ARG)
# Prompt exe
prompt?=echo -ne "\x1b[33m $(1) Sure ? [y/N]\x1b[m" && read ans && [ $${ans:-N} = y ]

help:
	@echo "[======== Ansible Help ========]"
	@echo "Usage: make <playbook> (ARG=<your-arg>)"
	@echo "Available PLAYBOOKS: $(PLAYBOOKS)"
	@$(MAKE) help_more || true
	@echo "[========== OPTIONS ===========]"
	@echo "keyboard_mac: $(keyboard_mac)"
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
