#!/usr/bin/env bash

VM_RECIPES=('dev.python-vm' 'ops.vagrant')
ANSIBLE_RECIPES=('ops.role' 'ops.playbook')
RECIPE=
REPLACE=<<EOF
s/REPOSITORY/${REPOSITORY}/
s/RECIPE/${RECIPE}/
EOF

# process() {

# }

process_vm() {
    local manala=$(cat vm.manala.yaml)

}

process_ansible() {
    echo "[ === test ansible recipe $1 === ]"
    cd $1 && manala up
}

array_contain() {
    local array=$1
    local needle=$2
    [[ " ${array[@]} " =~ " ${needle} " ]] && return 0 || return 1
}

guess_test() {
    array_contain $VM_RECIPES $1 && process_vm $1
    array_contain $ANSIBLE_RECIPES $1 && process_ansible $1
}

test_loop() {
    for d in */ ; do
        RECIPE=${d}
        echo "[ === process ${RECIPE} === ]"
        CURR_DIR=.tests/${d}
        mkdir ${CURR_DIR}
        guess_test ${d}
        rm -rf ${CURR_DIR}
    done
}

test_loop