#!/bin/bash
# ==========
# Playbook worker script
# Execute playbook from a virtual environement
# Usage : 
#   ./playbook-worker.sh or globally : mv playbook-worker.sh /usr/local/bin/playbook-worker
# Arguments : 
#   $1 : <git playbook url> Example: "https://github.com/g4-dev/playbook-ecs"
#   $2 : <inventory name> (corresponding to inventories path in playbook root) Example: "dev"
#   $3 : <custom sub playbook> Example: "database" (without the .yml)
# ==========
# TODO: check function python3 / ansible

run_playbook(){
    if [ ! -z "$3" ]; then
        ansible-playbook -K -i ./inventories/$2 $3.yml
    elif [ ! -z "$2" ]; then
        ansible-playbook -K -i ./inventories/$2 site.yml
    else
        ansible-playbook -K site.yml
    fi
}

first_check(){
    if [ -z "$1" ]; then
        stop_error "Should at least provide a git playbook url";
    fi
}

in_playbook_check(){
    if [ -z "$2" ] && [ -z `ls ./inventories/$2` ]; then
        stop_error "This inventory doesn't exist";
    fi

    if [ -z "$3" ] && [ -z `ls ./$3.yml` ]; then
        stop_error "This playbook doesn't exist";
    fi
}

init_playbook() {
  cd /tmp
  PLAYBOOK=`ls $(basename "$1" .git)`
  if [ ! -z "$PLAYBOOK" ]; then 
    cd $PLAYBOOK
    git fetch origin master && git reset --hard origin/master
    return
  fi

  git clone "$1" && cd "$(basename "$1" .git)"
}

stop_error() {
    echo -e "\e[01;31m$1\e[0m" >&2;
    exit 1;
}

# Verify arguments
first_check $1 $2 $3
# Clone or update playbook
init_playbook $1
# Execute it
run_playbook $1 $2 $3
