#!/bin/bash

export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
export KUBECONFIG="$PWD/kube/config"

pods=$(kubectl -n eirini get pods --no-headers=true | grep --invert-match Terminating)
if [ "$pods" != "" ]; then
  echo "There are leftover pods in the eirini namespace:"
  echo "$pods"
  exit 1
fi
