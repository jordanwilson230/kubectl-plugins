#!/usr/bin/env bash

# Remove the pod we've deployed
trap 'kubectl delete pod $container >/dev/null 2>&1 &' 0 1 2 3 15

# Here we restrict the number of pods/sessions to 2. Can be changed if you desire.
test "$(exec kubectl get po docker 2>/dev/null)" && container='docker-1' || container='docker'

POD=${1}
COMMAND=${2:-bash}

KUBECTL=${KUBECTL_PLUGINS_CALLER}
NAMESPACE="${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE:-$KUBECTL_PLUGINS_CURRENT_NAMESPACE}"
USER=${KUBECTL_PLUGINS_LOCAL_FLAG_DOCKERUSER}
export CONTAINER=${KUBECTL_PLUGINS_LOCAL_FLAG_CONTAINER}

NODENAME=$( $KUBECTL --namespace ${NAMESPACE} get pod ${POD} -o go-template='{{.spec.nodeName}}' )

# Adds toleration if the target container runs on a tainted node. Assumes no more than one taint. Change if yours have more than one.
TOLERATION_VALUE=$($KUBECTL --namespace ${NAMESPACE} get pod ${POD} -ojsonpath='{.spec.tolerations[].value}') >/dev/null 2>&1
if [[ "$TOLERATION_VALUE" ]]; then
    TOLERATION_KEY=$($KUBECTL --namespace ${NAMESPACE} get pod ${POD} -ojsonpath='{.spec.tolerations[].key}')
    TOLERATIONS='"tolerations": [{"effect": "NoSchedule","key": "'$TOLERATION_KEY'","operator": "Equal","value": "'$TOLERATION_VALUE'"}],'
    NODESELECTOR='"nodeSelector": {"kubernetes.io/hostname": "'$NODENAME'","'$TOLERATION_KEY'": "'$TOLERATION_VALUE'"},'
else
    TOLERATIONS=''
    NODESELECTOR='"nodeSelector": {"kubernetes.io/hostname": "'$NODENAME'"},'
fi

if [[ -n ${CONTAINER} ]]; then
  DOCKER_CONTAINERID=$( eval $KUBECTL --namespace ${NAMESPACE} get pod ${POD} -o go-template="'{{ range .status.containerStatuses }}{{ if eq .name \"${CONTAINER}\" }}{{ .containerID }}{{ end }}{{ end }}'" )
else
  DOCKER_CONTAINERID=$( $KUBECTL --namespace ${NAMESPACE} get pod ${POD} -o go-template='{{ (index .status.containerStatuses 0).containerID }}' )
fi
CONTAINERID=${DOCKER_CONTAINERID#*//}

read -r -d '' OVERRIDES <<EOF
{
    "apiVersion": "v1",
    "spec": {
        "containers": [
            {
                "image": "docker",
                "name": "'$container'",
                "stdin": true,
                "stdinOnce": true,
                "tty": true,
                "restartPolicy": "Never",
                "args": [
                  "exec",
                  "-it",
                  "-u",
                  "${USER}",
                  "${CONTAINERID}",
                  "${COMMAND}"
                ],
                "volumeMounts": [
                    {
                        "mountPath": "/var/run/docker.sock",
                        "name": "docker"
                    }
                ]
            }
        ],

        $NODESELECTOR

        $TOLERATIONS

        "volumes": [
            {
                "name": "docker",
                "hostPath": {
                    "path": "/var/run/docker.sock",
                    "type": "File"
                }
            }
        ]
    }
}
EOF

eval kubectl run -it --rm --restart=Never --image=docker --overrides="'${OVERRIDES}'" $container
