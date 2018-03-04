#!/bin/bash -e


## Note: This plugin does not edit any files. Updates/changes will be piped to kubectl.

## Define some common vars
DOCKER_REGISTRY='us.gcr.io/bb-hub-01'

## Inspect user's args
[ -z "$KUBECTL_PLUGINS_LOCAL_FLAG_FILE" ] && echo -e "\nRequired Arg: --file\n" && exit 1
[ ! -z "$KUBECTL_PLUGINS_LOCAL_FLAG_PATH" ] && KUBECTL_PLUGINS_LOCAL_FLAG_FILE="${KUBECTL_PLUGINS_LOCAL_FLAG_PATH}/${KUBECTL_PLUGINS_LOCAL_FLAG_FILE}"
[ ! -f "$KUBECTL_PLUGINS_LOCAL_FLAG_FILE" ] && echo -e "\nUnable to locate the specified file.\n" && exit 1
[[ "$KUBECTL_PLUGINS_LOCAL_FLAG_DRY" == "true" ]] && KUBECTL_PLUGINS_LOCAL_FLAG_DRY="--dry-run" || KUBECTL_PLUGINS_LOCAL_FLAG_DRY=""
KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE="${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE:-$KUBECTL_PLUGINS_CURRENT_NAMESPACE}"


## If user passes the --image flag without a tag (i.e., -i zookeeper), search the docker registry and present a list of options.
if [[ ! -z "$KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE" ]] && [[ ! "$KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE" =~ ":" ]]; then
    IFS=$'\n'
    if [[ "$DOCKER_REGISTRY" =~ "gcr.io" ]]; then
        available_images=($(gcloud container images list-tags ${DOCKER_REGISTRY}/${KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE} --limit=20 --format='get(tags,timestamp.datetime)'))
        available_images=(${available_images[*]/#/$KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE:})
    else
        available_images=($(docker search --limit=25 "${DOCKER_REGISTRY}/$KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE"))
    fi

 # Print out versions
    echo ''
    for image in ${!available_images[@]}; do
        echo "${available_images[$image]/#/$image:  }" 
    done | grep -v STAR | sed 's|^\([0-9]:\)|\1 |g'

 # Set the version to user's selection
    echo -e "\n" ; read -p "Select the number of the image to deploy: " REPLY
    [[ "$DOCKER_REGISTRY" =~ "gcr.io" ]] && let REPLY=REPLY+1
    KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE=$(echo "${available_images[*]}" | grep -v STARS | head -n $REPLY | tail -n1 | cut -d $'\t' -f1 | cut -d ' ' -f1 | cut -d '/' -f2 | sed 's|latest\;||g')
    echo -e "\nSetting image to $KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE"
fi

# Set cluster specific values
cluster=$(kubectl config current-context | rev | cut -d '_' -f1 | rev)
context="gke_bb-hub-01_us-central1-a_${cluster}"

if [[ "$KUBECTL_PLUGINS_LOCAL_FLAG_FILE" =~ "external-dns" ]]; then
   scope=${cluster/hub-/} ; scope=${scope/hub/production}
   cat "$KUBECTL_PLUGINS_LOCAL_FLAG_FILE" | sed -e "s|--namespace=staging|--namespace=${scope}|g; s|Pixie|$cluster|g; s|current-context: \(.*\)|current-context: $context|g" | kubectl -n default apply -f - $KUBECTL_PLUGINS_LOCAL_FLAG_DRY
   exit 0
fi

## Set any environment/cluster/namespace specific variables that must be hardcoded
case $cluster in #$KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE in
  "hub-staging") CLUSTER_IP='10.43.240.4' ; DASHBOARD_URL_PREFIX='master.' ;;
  "hub-preprod") CLUSTER_IP='10.51.240.5' ; DASHBOARD_URL_PREFIX='preprod.' ;;
  "hub") CLUSTER_IP='10.51.240.6' ; DASHBOARD_URL_PREFIX='' ;;
  *) echo -e "\n\nInvalid namespace.\n" ; exit 1 ;;
esac

if [[ "$KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE" =~ "$DOCKER_REGISTRY" ]]; then
    kubectl plugin deploy -h
    echo -e "\nInvalid image: ${KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE}\nThe Docker Registry prefix should not be included when using the -i flag. Just use the image name.\nYou can change the default registry domain in the ~/.kube/plugins/deploy/deploy.sh file if needed."
    exit 1
fi


## Determine the resource(s) to be updated.
resource_type="$(kubectl apply -f ${KUBECTL_PLUGINS_LOCAL_FLAG_FILE} --dry-run -o=jsonpath='{.kind}')"

# If the file is a configmap
if [[ "$resource_type" =~ "ConfigMap" ]] || [[ "$resource_type" =~ "NetworkPolicy" ]] || [[ "$resource_type" =~ "CronJob" ]]; then
   cat "$KUBECTL_PLUGINS_LOCAL_FLAG_FILE" | sed -e "s|[Ss[Aa][Nn][Dd][Bb][Oo][Xx]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g; s|[Ss][Tt][Aa][Gg][Ii][Nn][Gg]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g; s|[Pp][Rr][Ee][Pp][Rr][Oo][Dd]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g; \
        s|[Pp][Rr][Oo][Dd][Uu][Cc][Tt][Ii][Oo][Nn]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g; s|\(.*\)https://\(.*\).dashboard.bitbrew.com|\1${DASHBOARD_URL_PREFIX}dashboard.bitbrew.com|g" | kubectl -n $KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE apply -f - $KUBECTL_PLUGINS_LOCAL_FLAG_DRY
   echo -e "Update Complete."
   exit 0
fi

# If statefulset or deployment, get the image name.
if [[ "$resource_type" =~ "StatefulSet" ]] || [[ "$resource_type" =~ "Deployment" ]]; then
  MANIFEST_IMAGE="$(kubectl -n ${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE} apply --dry-run -f ${KUBECTL_PLUGINS_LOCAL_FLAG_FILE} -o=jsonpath='{..image}')"
  RUNNING_IMAGE="$(kubectl -n ${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE} get -f ${KUBECTL_PLUGINS_LOCAL_FLAG_FILE} -o=jsonpath='{..containers..image}' 2>/dev/null)" || RUNNING_IMAGE=""
else
  echo -e "\nAn Unknown Resource Type was Defined. Exiting!\n"
  exit 1
fi


## Apply statefulset
# Replaces anything namespace specific in the file with the targeted namespace.
# If image is passed, tell kubectl to use that instead of what is in the user's manifest.
if [[ ! -z "$KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE" ]]; then
   KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE="${DOCKER_REGISTRY}/${KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE}"
   cat "$KUBECTL_PLUGINS_LOCAL_FLAG_FILE" | sed -e "s|${MANIFEST_IMAGE}|${KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE}|g; s|[Ss[Aa][Nn][Dd][Bb][Oo][Xx]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g; s|[Ss][Tt][Aa][Gg][Ii][Nn][Gg]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g; s|[Pp][Rr][Ee][Pp][Rr][Oo][Dd]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g; s|[Pp][Rr][Oo][Dd][Uu][Cc][Tt][Ii][Oo][Nn]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g" | kubectl -n ${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE} apply -f - $KUBECTL_PLUGINS_LOCAL_FLAG_DRY
   echo -e "\n\n### Summary ###\nNamespace: ${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}\nPrevious Image: ${RUNNING_IMAGE}\nCurrent Image:    ${KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE}\n"
else
   cat "$KUBECTL_PLUGINS_LOCAL_FLAG_FILE" | sed -e "s|[Ss[Aa][Nn][Dd][Bb][Oo][Xx]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g; s|[Ss][Tt][Aa][Gg][Ii][Nn][Gg]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g; s|[Pp][Rr][Ee][Pp][Rr][Oo][Dd]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g; s|[Pp][Rr][Oo][Dd][Uu][Cc][Tt][Ii][Oo][Nn]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g; s|clusterIP: [0-9][0-9]\(.*\)|clusterIP: $CLUSTER_IP|g" | kubectl -n $KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE apply -f - $KUBECTL_PLUGINS_LOCAL_FLAG_DRY
   echo -e "\n\n### Success ###\nNamespace: ${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}\nPrevious Image: ${RUNNING_IMAGE}\nCurrent Image: ${MANIFEST_IMAGE}\n"
fi
