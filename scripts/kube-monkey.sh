#!/bin/bash

set -e

REGION=${REGION-us-central1}
ZONE=${REGION}-a
CLUSTER_NAME=${CLUSTER_NAME-gitlab-cluster}
RBAC_ENABLED=${RBAC_ENABLED-true}
DIR=$(dirname "$(readlink -f "$0")")

$DIR/validations.sh

if $RBAC_ENABLED; then
  password=$(gcloud container clusters describe $CLUSTER_NAME --zone $ZONE --project $PROJECT --format='value(masterAuth.password)');
  kubectl --username=admin --password=$password create -f $DIR/kube-monkey-resources/kube-monkey-role.yaml;
fi

kubectl --namespace=kube-system create configmap km-config --from-file=config.toml=$DIR/kube-monkey-resources/km-config.toml

kubectl create -f $DIR/kube-monkey-resources/kube-monkey-deployment.yaml
