#!/bin/bash

# add this to crontab -e so that script runs every 60 seconds
# * * * * * /root/CheckDockerContainer4.0.sh

set -euo pipefail

FILE="dockerContainerStatus.txt"
CONTAINER_NAME="whoami_server"
NAMESPACE="Custom/Docker"
METRIC_NAME="ContainerHealthy"
REGION="eu-west-1"

HEALTH_STATUS=$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}no-healthcheck{{end}}' "$CONTAINER_NAME" 2>/dev/null || echo "not-found")
# 1 = healthy | 0 = unhealthy
if [ "$HEALTH_STATUS" = "healthy" ]; then
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
  --dimensions InstanceId="$INSTANCE_ID",ContainerName="$CONTAINER_NAME"
