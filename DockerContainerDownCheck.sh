#!/bin/bash

# add this to crontab -e so that script runs every 60 seconds
# * * * * * /root/CheckDockerContainer4.0.sh

set -euo pipefail

FILE="dockerContainerStatus.txt"
NAMESPACE="Custom/Docker"
METRIC_NAME="ContainerDown"
REGION="eu-west-1"

STOPPED_COUNT="$(docker info 2>/dev/null | awk -F': ' '/Stopped:/ {print $2}' | xargs)"

if [[ "$STOPPED_COUNT" =~ ^[0-9]+$ ]] && [ "$STOPPED_COUNT" -gt 0 ]; then
  echo "1" > "$FILE"
  VALUE=1
else
  echo "0" > "$FILE"
  VALUE=0
fi

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
