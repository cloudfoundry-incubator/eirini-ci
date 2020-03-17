#!/bin/bash

set -xeuo pipefail

export KUBECONFIG=kube/config

helm_delete_if_exists() {
  if ! output="$(helm del "$1" --purge 2>&1)"; then
    echo "$output" | grep --ignore-case "not found"
  fi
  kubectl delete namespace "$1" --ignore-not-found
}

helm_delete_if_exists kubecf

helm_delete_if_exists cf-operator
kubectl delete customresourcedefinitions,validatingwebhookconfigurations,mutatingwebhookconfigurations --all