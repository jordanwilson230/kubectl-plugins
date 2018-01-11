#!/bin/bash

#pod="${KUBECTL_PLUGINS_LOCAL_FLAG_POD}"
pod=$1


i=0
nodes=($(kubectl get pod  -lapp=${pod} -o json | jq -r '.items[] | .spec.nodeName'))


clear
echo -e "\n __________________________________________________________________________ \n|      POD       |              LOCATION              |     NODE IP                  "
echo -e "|--------------------------------------------------------------------------"
for node in ${nodes[@]}; do
echo -e "|  ${pod}-${i}     ${node}    $(kubectl get node ${node}  -o json | jq -r '.status.addresses' | jq -r '.[] | select(.type=="ExternalIP").address')    "
    let i=i+1
done
echo -e "|__________________________________________________________________________ \n"
