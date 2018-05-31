#!/bin/bash

set -e
#set -x

### step 1 - get short SHA
if [ -n "${DEPLOY_GIT_SHA}" ]
then
  DEPLOY_GIT_SHA=$(echo ${DEPLOY_GIT_SHA} | cut -c1-7)
else
  echo "no commit selected"
  exit 1
fi

# load client bundle from UCP
echo -e "\nLoading UCP client bundle..."
cd /var/lib/jenkins/ucp-bundle
eval $(<env.sh)
cd ${WORKSPACE}

# set environment variables for compose
export TAG="${DEPLOY_GIT_SHA}"

# deploy using docker stack deploy
docker stack deploy -c docker-compose-deploy.yml docker_demo
