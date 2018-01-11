#!/bin/bash -e


if [ -z "$KUBECTL_PLUGINS_LOCAL_FLAG_FILE" ]; then
  echo -e "\nRequired Arg: --file\n"
  exit 1
fi

if [[ ! -z "$KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE" ]] && [[ ! "$KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE" =~ ":" ]]; then
  IFS=$'\n'
  available_images=($(docker search --limit=100 "nexus.bitbrew.com/$KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE"))
  for image in ${!available_images[@]}; do echo "${available_images[$image]/#/$image:  }" | sed 's|^0:|  |g' ; done | sed 's|^\([0-9]:\)|\1 |g'
  echo -e "\nSelect the number of the image to deploy:"
  read REPLY
  KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE=$(echo "${available_images[*]}" | grep -v STARS | head -n $REPLY | tail -n1 | cut -d ' ' -f1 | cut -d '/' -f2)
  echo -e "\nSetting image to $KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE"
fi

if [ ! -z "$KUBECTL_PLUGINS_LOCAL_FLAG_PATH" ]; then
  KUBECTL_PLUGINS_LOCAL_FLAG_FILE="${KUBECTL_PLUGINS_LOCAL_FLAG_PATH}/${KUBECTL_PLUGINS_LOCAL_FLAG_FILE}"
fi

[ ! -f "$KUBECTL_PLUGINS_LOCAL_FLAG_FILE" ] && echo -e "\nUnable to locate the specified file.\n" && exit 1

KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE="${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE:-$KUBECTL_PLUGINS_CURRENT_NAMESPACE}"

if [[ "$KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE" =~ "nexus" ]]; then
	kubectl plugin deploy -h
	echo -e "\nInvalid image: ${KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE}\n"
        exit 1
fi

if [[ "$KUBECTL_PLUGINS_LOCAL_FLAG_DRY" == "true" ]]; then
  KUBECTL_PLUGINS_LOCAL_FLAG_DRY="--dry-run"
else
  export KUBECTL_PLUGINS_LOCAL_FLAG_DRY=""
fi

## Determine the resource(s) to be updated.
resource_type="$(kubectl apply -f ${KUBECTL_PLUGINS_LOCAL_FLAG_FILE} --dry-run -o=jsonpath='{.kind}')"

## If the file is a configmap
if [[ "$resource_type" =~ "ConfigMap" ]] || [[ "$resource_type" =~ "NetworkPolicy" ]]; then
   [[ "$KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE" == "production" ]] && KUBECTL_PLUGINS_TEMP_FLAG_NAMESPACE="" || KUBECTL_PLUGINS_TEMP_FLAG_NAMESPACE="${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}."
   cat "$KUBECTL_PLUGINS_LOCAL_FLAG_FILE" | sed -e "s|[Ss[Aa][Nn][Dd][Bb][Oo][Xx]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g; s|[Ss][Tt][Aa][Gg][Ii][Nn][Gg]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g; s|[Pp][Rr][Ee][Pp][Rr][Oo][Dd]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g; \
       s|[Pp][Rr][Oo][Dd][Uu][Cc][Tt][Ii][Oo][Nn]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g; s|https://dashboard.bitbrew.com|https://${KUBECTL_PLUGINS_TEMP_FLAG_NAMESPACE}dashboard.bitbrew.com|g" | kubectl -n $KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE apply -f - $KUBECTL_PLUGINS_LOCAL_FLAG_DRY
   echo -e "Updates applied."
   exit 0
elif [[ "$resource_type" =~ "StatefulSet" ]] || [[ "$resource_type" =~ "Deployment" ]]; then
  MANIFEST_IMAGE="$(kubectl -n ${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE} apply --dry-run -f ${KUBECTL_PLUGINS_LOCAL_FLAG_FILE} -o=jsonpath='{..image}')"
  RUNNING_IMAGE="$(kubectl -n ${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE} get -f ${KUBECTL_PLUGINS_LOCAL_FLAG_FILE} -o=jsonpath='{..containers..image}' 2>/dev/null)" || RUNNING_IMAGE=""
else
  echo -e "\nAn Unknown Resource Type was Defined\n"
  exit 1
fi

## Apply statefulset
 # If image is passed, tell kubectl to use that instead of what is written in the file.
if [[ ! -z "$KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE" ]]; then
   KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE="nexus.bitbrew.com/${KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE}"
   cat "$KUBECTL_PLUGINS_LOCAL_FLAG_FILE" | sed -e "s|${MANIFEST_IMAGE}|${KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE}|g; s|[Ss[Aa][Nn][Dd][Bb][Oo][Xx]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g; s|[Ss][Tt][Aa][Gg][Ii][Nn][Gg]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g; s|[Pp][Rr][Ee][Pp][Rr][Oo][Dd]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g; s|[Pp][Rr][Oo][Dd][Uu][Cc][Tt][Ii][Oo][Nn]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g" | kubectl -n ${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE} apply -f - $KUBECTL_PLUGINS_LOCAL_FLAG_DRY
   echo -e "\n\n### Summary ###\nNamespace: ${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}\nPrevious Image: ${RUNNING_IMAGE}\n Current Image:  ${KUBECTL_PLUGINS_LOCAL_FLAG_IMAGE}\n"
 # If not provided, use what is in the user supplied manifest.
else
   cat "$KUBECTL_PLUGINS_LOCAL_FLAG_FILE" | sed -e "s|[Ss[Aa][Nn][Dd][Bb][Oo][Xx]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g; s|[Ss][Tt][Aa][Gg][Ii][Nn][Gg]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g; s|[Pp][Rr][Ee][Pp][Rr][Oo][Dd]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g; s|[Pp][Rr][Oo][Dd][Uu][Cc][Tt][Ii][Oo][Nn]|${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}|g" | kubectl -n $KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE apply -f - $KUBECTL_PLUGINS_LOCAL_FLAG_DRY
   echo -e "\n\n### Success ###\nNamespace: ${KUBECTL_PLUGINS_LOCAL_FLAG_NAMESPACE}\nPrevious Image: ${RUNNING_IMAGE}\nCurrent Image: ${MANIFEST_IMAGE}\n"
fi

