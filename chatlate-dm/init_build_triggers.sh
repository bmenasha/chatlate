#!/bin/bash
set -x
set -o errexit

echo "Initializing Build Triggers"
WEBAPP_REPO=chatlate-webapp-java
TRANSLATE_REPO=chatlate-translate-java
WEBAPP_BUILD_TRIGGER_FILE=build_trigger.json
TRANSLATE_BUILD_TRIGGER_FILE=translate_build_trigger.json

add-apt-repository ppa:git-core/ppa -y
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
apt-get update -y
apt-get install git nodejs build-essential jq -y

PROJECT=$(gcloud info --format='value(config.project)')

###### Chat Webapp
# Create the build trigger.
cd ~/
cat > $WEBAPP_BUILD_TRIGGER_FILE <<- EOM
  {
    "triggerTemplate": {
      "projectId": "${PROJECT}",
      "repoName": "${WEBAPP_REPO}",
      "branchName": "master"
    },
    "description": "Chatlate Chat Application Build Trigger",
    "filename": "cloudbuild.yaml"
  }
EOM

curl -s -H"Authorization: Bearer $(gcloud config config-helper --format='value(credential.access_token)')" https://cloudbuild.googleapis.com/v1/projects/$PROJECT/triggers > existing_triggers.json
if ! cat existing_triggers.json | python -m json.tool | grep 'Chatlate Chat Application Build Trigger' -q ; then
 echo "Creating Build Trigger"
 curl -s -XPOST -T $WEBAPP_BUILD_TRIGGER_FILE -H"Authorization: Bearer $(gcloud config config-helper --format='value(credential.access_token)')" https://cloudbuild.googleapis.com/v1/projects/$PROJECT/triggers
fi


###### Translate Webapp
# Create the build trigger.
cd ~/
cat > $TRANSLATE_BUILD_TRIGGER_FILE <<- EOM
  {
    "triggerTemplate": {
      "projectId": "${PROJECT}",
      "repoName": "${TRANSLATE_REPO}",
      "branchName": "master"
    },
    "description": "Chatlate Translate Application Build Trigger",
    "filename": "cloudbuild.yaml"
  }
EOM

curl -s -H"Authorization: Bearer $(gcloud config config-helper --format='value(credential.access_token)')" https://cloudbuild.googleapis.com/v1/projects/$PROJECT/triggers > existing_triggers.json
if ! cat existing_triggers.json | python -m json.tool | grep 'Chatlate Translate Application Build Trigger' -q ; then
 echo "Creating Build Trigger"
 curl -s -XPOST -T $TRANSLATE_BUILD_TRIGGER_FILE -H"Authorization: Bearer $(gcloud config config-helper --format='value(credential.access_token)')" https://cloudbuild.googleapis.com/v1/projects/$PROJECT/triggers
fi

echo "Done Initializing Build Triggers"
