# Manala recipe Infra

This project is used to share reccurrent files between multiple projects

## TO DO

- [ ] manala template release system, branches in github actions + .releaserc
- [ ] `auto` option for ip (vagrant)
- [ ] paramiko mode for ansible (link with packer)
- [ ] port vue template here
- [ ] sf replace jenkins by circle / travis or github actions

## Doc

For all tools `manala` is required to sync recipes in all projects

`curl -sfL https://raw.githubusercontent.com/manala/manala/master/godownloader.sh | sh`

### 1. Vagrant module

[check project readme](https://github.com/loic-roux-404/vg-facade#readme)

### 2. Makefile modules

> Use makefile boilerplate for specific environments

#### 1. Ansible

- requirements : `yq` https://github.com/mikefarah/yq
- requirements : `ansible` (only mac & linux)

##### ops.playbook makefiles

Full Example to integrate make template and tools

Also docker module part to test running container

```Makefile
include .manala/ansible.mk
include .manala/docker.mk

DOCKER_IMG_PREFIX:=organisation
DOCKER_IMAGES:=$(notdir $(basename $(wildcard docker/*.Dockerfile)))
foo.sshPort:=22222

help_more:
	@echo "Fake deploy on inventory baz : $(addsuffix .debug.baz, $(PLAYBOOKS))"
	@echo "Docker service : $(addsuffix .docker-run, $(DOCKER_IMAGES)))"

# =============================
# Additionals playbook commands
# =============================
# Debug inventory baz
%.debug.baz: debug-deco
	$(eval INVENTORY:=./inventories/baz)
	$(eval OPTIONS+= -e ansible_user=vagrant)
	$(call playbook_exe)

# ======================
# Docker services
# ======================
# put ssh key in these containers
export PUB=$(shell cat ~/.ssh/id_rsa.pub)

# Test run container
%.docker-run:
  # export your Dockerfile required env vars 
	$(eval export USER=$*)
	$(eval IMAGE_TAG:=$(DOCKER_IMG_PREFIX)/$*)
	$(eval PORTS:=-p $($*.sshPort):22 -p 8300-8600:8300-8600)
	$(eval DOCKERFILE:=docker/$*.Dockerfile)
	$(call docker_run)

```
