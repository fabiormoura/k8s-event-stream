#!/usr/bin/env bash

cd "$(dirname "$0")"

VAGRANT_CWD=../cloud-management/provisioning/mini-local vagrant up
ANSIBLE_CONFIG=../cloud-management/configuration/kubespray/ansible.cfg ansible-playbook -i ../cloud-management/configuration/kubernetes-cluster/inventories/mini-local/inventory ../cloud-management/configuration/kubernetes-cluster/cluster.yml -b --flush-cache -v