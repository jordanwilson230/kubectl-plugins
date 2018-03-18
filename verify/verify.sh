#!/bin/bash


echo "$@" | grep "deploy\|create\|apply" 1>/dev/null

if [ $? -eq 0 ] && [[ ! "$@" =~ ' -s' ]] && [[ ! "$@" =~ ' --silent' ]]; then
  # Prompt user if issuing commands in production
  kubectl config get-contexts | grep -E '\*.*production' 1>/dev/null
  if [ $? -eq 0 ] && [[ "KUBECTL_PLUGINS_LOCAL_FLAG_QUIET" != "true" ]]; then
    clear; echo -e "\nYOU ARE OPERATING INSIDE A PRODUCTION NAMESPACE? Proceed?\n"
    read -p "[yes/no]: " answer
    if [[ "$answer" != "yes" ]]; then
      exit 1
    fi
    echo -e "\n\n"
  fi
fi
