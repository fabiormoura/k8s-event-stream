#!/usr/bin/env bash

cd "$(dirname "$0")"

KUBECONFIG=../cloud-management/configuration/kubectl/mini-local/config kubectl "$@"