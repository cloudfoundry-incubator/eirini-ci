#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

ibmcloud-login
export-kubeconfig "$CLUSTER_NAME"

kubectl config view --flatten >kube/config
