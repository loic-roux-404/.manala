#!/usr/bin/env bash

VM_RECIPES=('dev.python-vm' 'ops.vagrant')
ANSIBLE_RECIPES=('ops.role' 'ops.playbook')
REPOSITORY=$(pwd)

# TODO :
# _templating with sed
# _ manala up

process_test() {
    # Definitions
    local recipe=$1
    local file=$2
    REPLACE=<<EOF
s/REPOSITORY/${REPOSITORY}/
s/RECIPE/${1}/
EOF
    # launch
    cd .tests
    sed -f ${REPLACE} ${file} > ${recipe}/.manala.yaml
    cat ${recipe}/.manala.yaml
    cd -
}

contains() {
    local needle="$1"
    shift 1;
    local arr=( "$@" )

    for v in "${arr[@]}"; do
        if [ "$v" == "$needle" ]; then
            return 0;
        fi
    done
   return 1;
}

guess_test() {
    contains $1 "${VM_RECIPES[@]}" \
        && process_test $1 vm.manala.yaml \
        && return 0;

    contains $1 "${ANSIBLE_RECIPES[@]}" \
        && process_test $1 ansible.manala.yaml \
        && return 0;

    process_test $1 classic.manala.yaml;
}

test_loop() {
    for d in */ ; do
        RECIPE=${d///} # remove the /
        CURR_DIR=.tests/${d}
        mkdir ${CURR_DIR}
        touch ${CURR_DIR}/.manala.yaml

        guess_test ${RECIPE}

        rm -rf ${CURR_DIR}
    done
}

test_loop