#!/usr/local/bin/bash
set -euo pipefail

echo -e "Iterating...\n"

nodes=$(kubectl get node --no-headers -o custom-columns=NAME:.metadata.name)

declare -A zones

for node in $nodes; do
  zone="$(kubectl get node $node -o go-template='{{ index .metadata.labels "failure-domain.beta.kubernetes.io/zone" }}{{printf "\n"}}')"
  pods=$(kubectl describe node "$node" | sed '1,/Non-terminated Pods/d' | sed '/Allocated resources/,$ d' | tail -n +3 | awk '{b=$1","$2; print b}')
  zones[$zone]="$pods ${zones[$zone]-}"
done

for zoneName in ${!zones[@]}; do
  echo $zoneName
  echo ${zones[$zoneName]} | tr ' ' '\n' | sort
  echo
done

