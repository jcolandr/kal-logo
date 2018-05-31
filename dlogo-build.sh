#!/bin/bash
set -e
#set -x

### step 1 - check for prerequisites
# check for UCP client bundle
if [ ! -f /var/lib/jenkins/ucp-bundle/env.sh ]
then
  echo -e "\nERROR - Missing client bundle; please execute 'util > client-bundle'"
  exit 1
else
  echo -e "\nOK - Client bundle found"
fi


### step 2 - build the docker image
# find the short git SHA
GITID=$(echo ${GIT_COMMIT} | cut -c1-7)

# load client bundle from UCP
echo -e "\nLoading UCP client bundle and connecting to local Docker engine..."
cd /var/lib/jenkins/ucp-bundle
eval $(<env.sh)
rm -rf dlogo
git clone https://github.com/jcolandr/dlogo.git
cd dlogo

# set environment variable to be able to talk directly to the docker engine instead of UCP cluster
DOCKER_HOST=tcp://${JENKINS_IP}:12376

# build the demo using the existing Dockerfile and tag the image with the short git SHA
echo -e "\nBuilding ${DTR_URL}/dev/dlogo:${GITID}..."
docker build -t ${DTR_URL}/dev/dlogo:${GITID} .


### step 4 - push the new docker image to DTR with signature

echo -e "\nTagging ${DTR_URL}/dev/dlogo:${GITID} as ${DTR_URL}/dev/dlogo:latest to DTR"
docker tag ${DTR_URL}/dev/dlogo:${GITID} ${DTR_URL}/dev/dlogo:latest
docker tag ${DTR_URL}/dev/dlogo:${GITID} ${DTR_URL}/stage/dlogo:${GITID}
docker tag ${DTR_URL}/dev/dlogo:${GITID} ${DTR_URL}/stage/dlogo:stable
docker login -u demo -p docker123 ${DTR_URL}

echo -e "\nPushing ${DTR_URL}/dev/dlogo:latest to DTR"
docker push ${DTR_URL}/dev/dlogo:latest

echo -e "\nPushing ${DTR_URL}/demo/docker-demo:${GITID} to DTR"
docker push ${DTR_URL}/dev/dlogo:${GITID}
docker push ${DTR_URL}/stage/dlogo:${GITID}
docker push ${DTR_URL}/stage/dlogo:latest

echo -e "\nBuild complete."
