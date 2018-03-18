#!/bin/bash


cluster='gke_MyProject_myZone_' # Sets our base cluster name, ommitting any cluster specific name. If one of my clusters name is gke_MyProject_myZone_sandbox, then eexecuting 'kubectl switch cluster sandbox' will switch the cluster context to sandbox.

if [[ "$@" =~ "cluster" ]]; then
    if [ ! -z $3 ]; then # They're passing the cluster to switch to.
      cluster_suffix=${3/#/-} # ie., passing the args, cluster preprod, the cluster name becomes gke_bb-hub-01_us-central1-a_hub-preprod
      [[ "$3" =~ "gke" ]] && cluster="$3" && cluster_suffix=""
      kubectl config use-context ${cluster}${cluster_suffix} 1>/dev/null
    fi
fi

if [[ ! "$@" =~ "cluster" ]] && [[ ! "$@" == "" ]]; then
  kubectl config set-context $(kubectl config current-context) --namespace="$2" 1>/dev/null
fi

kubectl config get-contexts | head -n1; kubectl config get-contexts | sed 1d | sort --key=3
