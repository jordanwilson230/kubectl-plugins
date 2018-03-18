#!/bin/bash

! $(hash jq 2>/dev/null) && echo -e "\nMissing dependency: jq\n" && exit
## Read user args
pod="${KUBECTL_PLUGINS_LOCAL_FLAG_POD:-}"
[ -z "$KUBECTL_PLUGINS_LOCAL_FLAG_POD" ] && echo -e "\nPlease provide pod name [-p flag].\n" && exit

username="jordan"
user="${KUBECTL_PLUGINS_LOCAL_FLAG_USER:-}"
[ ! -z "$user" ] && user='-u '$user'' || echo -e "No user specified [-u]. Using default...\n"
command="${command:-bash}"


## Get node. If no value is returned, assume no pod found.
node_name=$(kubectl get pod ${pod} -o json | jq -r '.spec.nodeName')
[ -z "$node_name" ] && exit

## Get node IP
node_ip=$(kubectl get node ${node_name}  -o json | jq -r '.status.addresses' | jq -r '.[] | select(.type=="ExternalIP").address')

## Get container
container="$(kubectl get po "$pod" -o json | grep  '"containerID"' | head -n1 | cut -d '/' -f3 | cut -b1-12)"

## SSH to container
ssh -t ${username}@${node_ip} "docker exec -it $user $container $command"  2>/dev/null
