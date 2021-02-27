# Manala recipe Infra

This project is used to share reccurrent files between multiple projects

## TO DO

- [ ] `auto` option for ip (vagrant)
- [ ] paramiko mode for ansible (link with packer)
- [ ] port vue template here
- [ ] sf replace jenkins by circle / travis or github actions

## Doc

For all tools `manala` is required to sync recipes in all projects

`curl -sfL https://raw.githubusercontent.com/manala/manala/master/godownloader.sh | sh`

#### 1. Vagrant module

#### Requirements

- `python3`
- `vagrant`
- `ruby` (>= 2.3)

### Vagrant plugin Context

This plugin is a **facade** aimed at setting easily a virtual vagrant environment

Goal is to provide reusable preconfigured set of tools and Organisation on **vagrant environments** with like :

- VM Config sugar
- Shared folders configured
- Easier Networking
- Issues Workarounds
- Others

---

#### Full config.yaml
> !! Always create this file (`touch config.yaml`)

> Use this same schema in manala.yaml to share a default config

> All variables are set to their default value

```yaml

domain: localhost # format : domain.tld (landrush used)
box: loic-roux-404/deb64-buster # Vagrant cloud box
vb_guest_update: false # Update VirtualBox Guest Additions (for shared folders)
box_update: false # Update box from vagrant cloud
box_version: null # Choose a valid box version
git:
  org: null # provide an username to clone your playbook
  provider: https:#github.com # can be https:#gitlab.com

paths:
  web: null # not used for now
  host: ./ # Project path on your machine (used by shared folders)
  guest: /vagrant # Project path on guest machine (used by shared folders)

network:
  ip: 192.168.33.10 #NEED TO ADAPT TO YOUR CONFIG
  type: private # Available public private (check vagrant doc)
  dns: true
  # Specify object of type for each port
  # {
  #    guest: 80 # (required)
  #    host: 8080 # (required)
  #    auto_correct: true # (optional)
  #    disabled: false (optional)
  # }
  ports: []
  # NOT TESTED
  # add cert in your machine to enable ssl
  ssl:
    cert: null # cert filename
    path: /etc/ssl # cert path in guest

ansible:
  disabled: false
  playbook: null # git repository name
  inventory: null # Choose inventory (ex : dev prod staging)
  # AVAILABLE :
  # - worker (see script header for playbook-worker.sh)
  # - classic (need ansible on your machine)
  # - local (need ansible on guest machine)
  type: local
  sub_playbook: site.yml # Execute another file under playbook root instead of default site.yml
  vars: # extra_vars for ansible
    keyboard_mac: false

fs:
  type: rsync # AVAILABLE : nfs smb vbox (need vb_guest_update = true)
  opts:
    auto: true # watch enable for rsync
    disabled: true # for all
    ignored: # ignored files in rsync
      - /**/.DS_Store
      - .git
      - .vagrant
      - .idea/
      - .vscode/

provider:
  type: virtualbox # Only Virtualbox available for now
  # Refer to Virtualbox original documentation or `VBoxManage --help `
  # define parameter to the VBoxManage command used by vagrant
  # Params are defined in the config.json file with name=param pair
  # We use this syntax sugar to loop and create dynamic virtualbox vm settings
  # By default vm is modified to 1024Mo RAM & 2 CPU's
opts:
  memory: 2048
  cpus: 2
  ioapic: on
  # Others settings example
  cpuexecutioncap: 80
  natdnsproxy1: on
  natdnshostresolver1: on
  nictrace1: on
  nictracefile1: .vagrant/dump.pcap
  cableconnected1: on

```

## Contribute

#### Error Handling

Component.rb has a class error where your can build complex error to help user

**All** : All these errors have a field `concerned`
which can be string or array of config identifier (ex identifier: `config.network.type`)

**standard** : simply pass the second arg of Error.new for message

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
