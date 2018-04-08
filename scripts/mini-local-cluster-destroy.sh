#!/usr/bin/env bash

cd "$(dirname "$0")"

VAGRANT_CWD=../cloud-management/provisioning/mini-local vagrant destroy -f