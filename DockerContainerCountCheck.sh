#!/bin/bash

# This script will query docker info and push the running container count to an output file called dockercontainercount.txt,
# and push customer metric(ContainerCount) to Cloudwatch

#1) install crond
#2) add this via crontab -e so that script runs every 10 minutes
#   */10 * * * * /root/DockerContainerCountCheck.sh
#3) install AWS CLI or the script will fail

set -euo pipefail

FILE="dockerContainerCount.txt"
NAMESPACE="Custom/Docker"
METRIC_NAME="ContainerCount"
REGION="us-east-2"

RUNNING_COUNT="$(docker info 2>/dev/null | awk -F': ' '/Running:/ {print $2}' | xargs)"

# ************* comment out after testing *****
#1) comment out */10 * * * * /root/DockerContainerCountCheck.sh via crontab -e, so that script in crontab does not run
#2) uncomment out the two lines below and set RUNNING_COUNT to correct value
#3) Run scirpt manually ./DockerContainerCountCheck

#RUNNING_COUNT=?
#echo "$RUNNING_COUNT"

# ************* end testing *****




VALUE=1
if [[ "$RUNNING_COUNT" =~ ^[0-9]+$ ]] && [ "$RUNNING_COUNT" -gt 1 ]; then
  VALUE="$RUNNING_COUNT"
fi

echo "$VALUE" > "$FILE"


TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

INSTANCE_ID=$(curl -s \
  -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)


aws cloudwatch put-metric-data \
  --namespace "$NAMESPACE" \
  --metric-name "$METRIC_NAME" \
  --value "$VALUE" \
  --unit Count \
  --region "$REGION" \
  --dimensions InstanceId="$INSTANCE_ID"



#echo $NAMESPACE
#echo $METRIC_NAME
#echo $VALUE
#echo $REGION
#echo $INSTANCE_ID
