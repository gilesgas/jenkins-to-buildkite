#!/bin/bash
set -euo pipefail

JENKINS_URL="http://localhost:8080"
JOB_PATH="job/jenkins-jcasc-example/job/main"
USER="admin"
TOKEN="admin"

echo "--- :docker: Stand up the cluster"
docker-compose up -d
sleep 60

echo "--- :sleuth_or_spy: Check that the agents are online"
curl -s -u "$USER:$TOKEN" "$JENKINS_URL/computer/api/json" |
  jq -e '[.computer[].displayName] | contains(["agent1", "agent2"])'

echo "--- :wrench: Trigger a build job"
curl -s -u "$USER:$TOKEN" -c cookies.txt "$JENKINS_URL/crumbIssuer/api/json" -o crumb.json
CRUMB=$(jq -r '.crumb' < crumb.json)
QUEUE_URL=$(curl -s -u "$USER:$TOKEN" -b cookies.txt -H "Jenkins-Crumb: $CRUMB" -D - -X POST "$JENKINS_URL/$JOB_PATH/build" | grep -Fi Location | awk '{print $2}' | tr -d '\r')
echo "🔄 Build queued at: $QUEUE_URL"

while true; do
  BUILD_JSON=$(curl -s -u "$USER:$TOKEN" "${QUEUE_URL}api/json")
  BUILD_NUMBER=$(echo "$BUILD_JSON" | jq -r '.executable.number // empty')

  if [[ -n "$BUILD_NUMBER" ]]; then
    echo "🚀 Build started: #$BUILD_NUMBER"
    break
  fi

  sleep 1
done

BUILD_URL="$JENKINS_URL/$JOB_PATH/$BUILD_NUMBER"

while true; do
  STATUS_JSON=$(curl -s -u "$USER:$TOKEN" "$BUILD_URL/api/json")
  BUILDING=$(echo "$STATUS_JSON" | jq -r '.building')

  if [[ "$BUILDING" == "false" ]]; then
    RESULT=$(echo "$STATUS_JSON" | jq -r '.result')
    echo "✅ Build completed with result: $RESULT"
    break
  fi
  
  echo "⏳ Still building..."
  sleep 2
done

echo "--- :spiral_note_pad: Emit the Jenkins job logs"
curl -s -u "$USER:$TOKEN" "$BUILD_URL/consoleText"

echo "--- :docker: Emit the Docker Compose logs"
docker-compose logs

echo "--- :arrow_down: Shut down the cluster"
docker-compose down --rmi all
