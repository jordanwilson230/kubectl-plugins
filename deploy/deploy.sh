#!/bin/bash -e


## Note: This plugin does not edit any files. Updates/changes will be piped to kubectl.

## Define some common vars
DOCKER_REGISTRY='us.gcr.io/myProject'

## Inspect user's args
FILE="${KUBECTL_PLUGINS_LOCAL_FLAG_FILE:-}"
[[ ! "$FILE" ]] && echo -e "\nRequired Arg: --file\n" && exit 1
[[ "$KUBECTL_PLUGINS_LOCAL_FLAG_PATH" ]] && FILE="${KUBECTL_PLUGINS_LOCAL_FLAG_PATH}/${FILE}" # Append fullpath to filename given
[ ! -f "$FILE" ] && echo -e "\nUnable to locate the specified file.\n" && exit 1
[[ "$KUBECTL_PLUGINS_LOCAL_FLAG_DRY" == "true" ]] && DRY="--dry-run" || DRY=""
NAMESPACE="${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE:-$KUBECTL_PLUGINS_CURRENT_NAMESPACE}"
IMAGE="${KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE:-}"

[[ "$IMAGE" =~ "$DOCKER_REGISTRY" ]] && IMAGE=${IMAGE/$DOCKER_REGISTRY\/}

## If user passes the --image flag without a tag (i.e., -i zookeeper), search the docker registry and present a list of options.
if [[ "$IMAGE" ]] && [[ ! "$IMAGE" =~ ":" ]]; then
    IFS=$'\n'
    case "$DOCKER_REGISTRY" in
        *"gcr.io"*)
          available_images=$(gcloud container images list-tags ${DOCKER_REGISTRY}/${IMAGE} --limit=20 --format='(digest,tags,timestamp.datetime)' | grep -v TAGS) ;;
        *)
        available_images=($(docker search --limit=25 "${DOCKER_REGISTRY}/$IMAGE" | grep -v 'TAG\|STAR')) ;;
    esac

# Print the search results
    count=1
    echo;
    for image in $available_images ; do
        echo $image $'\t' \=\> \# [ $count ]
        let count=count+1
    done

# Set the version to user's selection
    echo -e "\n" ; read -p "Select the number of the image to deploy: " REPLY
    TAG=$(echo "$available_images" | grep -v TAGS | head -n $REPLY | tail -n1 | cut -d ',' -f1 | sed 's|[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\(.*\)||g' | cut -d ' ' -f2-3 | tr -d ' ')
    IMAGE="${DOCKER_REGISTRY}/${IMAGE}:${TAG}"
    echo -e "\nSetting image to $IMAGE"
fi

## Determine the resource(s) to be updated.
resource_type="$(kubectl apply -f ${FILE} --dry-run -o=jsonpath='{.kind}')"

# If the file is a configmap, cronjob, or rbac
if [[ "$resource_type" =~ "ConfigMap" ]] || [[ "$resource_type" =~ "ClusterRoleBinding" ]] || [[ "$resource_type" =~ "ClusterRole" ]] || [[ "$resource_type" =~ "RoleBinding" ]] || [[ "$resource_type" =~ "ServiceAccount" ]] || [[ "$resource_type" =~ "NetworkPolicy" ]] || [[ "$resource_type" =~ "CronJob" ]]; then
   cat "$FILE" | sed -e "s|[Ss[Aa][Nn][Dd][Bb][Oo][Xx]|${NAMESPACE}|g; s|[Ss][Tt][Aa][Gg][Ii][Nn][Gg]|${NAMESPACE}|g; s|[Pp][Rr][Ee][Pp][Rr][Oo][Dd]|${NAMESPACE}|g; \
        s|[Pp][Rr][Oo][Dd][Uu][Cc][Tt][Ii][Oo][Nn]|${NAMESPACE}|g" | kubectl -n $NAMESPACE apply -f - $DRY
   echo -e "Update Complete."
   exit 0
fi

# If statefulset or deployment, get the image name.
if [[ "$resource_type" =~ "StatefulSet" ]] || [[ "$resource_type" =~ "Deployment" ]]; then
  MANIFEST_IMAGE="$(kubectl -n ${NAMESPACE} apply --dry-run -n null -f ${FILE} -o=jsonpath='{..image}')"
  RUNNING_IMAGE="$(kubectl -n ${NAMESPACE} get -f ${FILE} -o=jsonpath='{..containers..image}' 2>/dev/null)" || RUNNING_IMAGE=""
else
  echo -e "\nAn Unknown Resource Type was Defined. Exiting!\n"
  exit 1
fi


## Apply statefulset
# Replaces anything namespace specific in the file with the targeted namespace.
# If image is passed, tell kubectl to use that instead of what is in the user's manifest.
if [[ ! -z "$IMAGE" ]]; then
   IMAGE="${IMAGE}"
   cat "$FILE" | sed -e "s|${MANIFEST_IMAGE}|${IMAGE}|g; s|[Ss[Aa][Nn][Dd][Bb][Oo][Xx]|${NAMESPACE}|g; s|[Ss][Tt][Aa][Gg][Ii][Nn][Gg]|${NAMESPACE}|g; s|[Pp][Rr][Ee][Pp][Rr][Oo][Dd]|${NAMESPACE}|g; s|[Pp][Rr][Oo][Dd][Uu][Cc][Tt][Ii][Oo][Nn]|${NAMESPACE}|g" | kubectl -n ${NAMESPACE} apply -f - $DRY
   echo -e "\n\n### Summary ###\nNamespace: ${NAMESPACE}\nPrevious Image: ${RUNNING_IMAGE}\nCurrent  Image: ${IMAGE}\n"
else
   cat "$FILE" | sed -e "s|[Ss[Aa][Nn][Dd][Bb][Oo][Xx]|${NAMESPACE}|g; s|[Ss][Tt][Aa][Gg][Ii][Nn][Gg]|${NAMESPACE}|g; s|[Pp][Rr][Ee][Pp][Rr][Oo][Dd]|${NAMESPACE}|g; s|[Pp][Rr][Oo][Dd][Uu][Cc][Tt][Ii][Oo][Nn]|${NAMESPACE}|g; s|clusterIP: [0-9][0-9]\(.*\)|clusterIP: $CLUSTER_IP|g" | kubectl -n $NAMESPACE apply -f - $DRY
   echo -e "\n\n### Success ###\nNamespace: ${NAMESPACE}\nPrevious Image: ${RUNNING_IMAGE}\nCurrent  Image: ${MANIFEST_IMAGE}\n"
fi
