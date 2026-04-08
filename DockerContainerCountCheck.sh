#!/bin/bash

# This script will query docker info and push the running container count to an output file called dockercontainercount.txt,
# and push customer metric(ContainerCount) to Cloudwatch

# add this to crontab -e so that script runs every 10 minutes
# */10 * * * * /root/DockerContainerDownCheck.sh

set -euo pipefail

FILE="dockerContainerCount.txt"
NAMESPACE="Custom/Docker"
METRIC_NAME="ContainerCount"
REGION="eu-west-1"

RUNNING_COUNT="$(docker info 2>/dev/null | awk -F': ' '/Running:/ {print $2}' | xargs)"

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
