#!/bin/bash


if [[ "$@" == "" ]]; then
  echo -e "\nMissing namespace/cluster"
  exit 0
fi

if [[ "$@" =~ "cluster" ]]; then
  kubectl config use-context $(kubectl config get-contexts | grep -v '*' | tail -n1 | awk '{print $1 }')
else
  kubectl config set-context $(kubectl config current-context) --namespace="$2"
fi

kubectl config get-contexts
