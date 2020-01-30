#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

readonly CLUSTER_DIR="environments/kube-clusters/$CLUSTER_NAME"
readonly BITS_SECRET="bits"

main() {
  set-kube-state
  copy-output
}

set-kube-state() {
  local cluster_domain
  cluster_domain="${CLUSTER_NAME}.ci-envs.eirini.cf-app.com"

  pushd cluster-state
  mkdir --parent "$CLUSTER_DIR"
  cat >"$CLUSTER_DIR"/scf-config-values.yaml <<EOF
bits:
  env:
    DOMAIN: $cluster_domain
  ingress:
    endpoint: $cluster_domain
    use: true
    annotations:
      kubernetes.io/ingress.class: "nginx"
      cert-manager.io/cluster-issuer: "letsencrypt-dns-issuer"
  secrets:
    BITS_SERVICE_SECRET: $BITS_SECRET
    BITS_SERVICE_SIGNING_USER_PASSWORD: $BITS_SECRET
    BLOBSTORE_PASSWORD: $BITS_SECRET
  useExistingSecret: true

env:
    DOMAIN: $cluster_domain
    UAA_HOST: uaa.$cluster_domain
    UAA_PORT: 443
    UAA_PUBLIC_PORT: 443

kube:
    storage_class:
      persistent: standard
      shared: standard
    auth: rbac

secrets:
    CLUSTER_ADMIN_PASSWORD: $CLUSTER_ADMIN_PASSWORD
    UAA_ADMIN_CLIENT_SECRET: $UAA_ADMIN_CLIENT_SECRET
    BLOBSTORE_PASSWORD: $BITS_SECRET

ingress:
  enabled: true
  annotations:
    "nginx.ingress.kubernetes.io/proxy-body-size": "100m"
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-dns-issuer"

eirini:
  opi:
    use_registry_ingress: true
    ingress_endpoint: $cluster_domain

  secrets:
    BLOBSTORE_PASSWORD: $BITS_SECRET
sizing:
  router:
    count: 2

EOF
  popd
}

copy-output() {
  pushd cluster-state || exit
  if git status --porcelain | grep .; then
    echo "Repo is dirty"
    git add "$CLUSTER_DIR/scf-config-values.yaml"
    git config --global user.email "eirini@cloudfoundry.org"
    git config --global user.name "Come-On Eirini"
    git commit --all --message "update/add scf values file"
  else
    echo "Repo is clean"
  fi
  popd || exit

  cp -r cluster-state/. state-modified/
}

main
