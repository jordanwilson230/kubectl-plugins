#!/bin/bash

case $@ in
    *"login"*)
    docker login -u oauth2accesstoken -p "$(gcloud auth print-access-token)" https://us.gcr.io ;;
    *)
     echo -e "\nUsage: kubectl docker --login [or -l]\n" && exit 1
    ;;
esac


