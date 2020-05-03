# Manala recipe Infra

This project is used to share reccurrent files between multiple projects

## Doc

#### 1. Vagrant module
> Configure Vagrantfile from json file
# Doc for vagrant404 module

## Context 

This plugin is aimed at setting a virtual environment for
web servers or ansible playbook debugging with real production simulation

Goal is to provide reusable set of tools and Organisation on **vagrant environments** with like :
- Makefile target (web module != playbook module)
- VM Config sugar
- Shared folders
- Easier Networking
- Issues Workarounds
- Others

## Requirements

- ruby (2.5)
- python
- jq (from your platform package manager)
- manala

`curl -sL https://gist.githubusercontent.com/loic-roux-404/e9b972dc0d933c8645dc796aaf29a7d3/raw/0174e66086c63211293bba64e67bd8fe26a58d6f/manala.sh | sh`

## Vm Settings
---
### 1. Base
> Base config assemble fixes, box and vb guest update option.

### 3. Providers
>#### Here the list of useful parameters to configure a virtualbox machine

### virtualbox

Refer to Virtualbox original documentation or `VBoxManage --help `
define parameter to the VBoxManage command used by vagrant
Params are defined in the config.json file with name=param pair
We use this syntax sugar to loop and create dynamic virtualbox vm settings

```
"vm" : {
    // Defaults variable and values
    "memory": "2048"
    "cpus" : "2"
    "ioapic" : "on",
    // Other settings
    "cpuexecutioncap": "80",
    "natdnsproxy1": "on",
    "natdnshostresolver1": "on",
    "nictrace1": "on",
    nictracefile1": ".vagrant/dump.pcap",
    cableconnected1': 'on'
}
```

### 4. Network / DNS

### 5. Shared folders

#### 2. Makefile modules
> Use makefile boilerplate for specific environments

# 1. Ansible