#!/bin/bash

ALB_DNS="$1"

if [ -z "$ALB_DNS" ]; then
  echo "Usage: $0 <alb-dns-name>"
  echo "Example: $0 tech-eazy-app-lb-123456.ap-south-1.elb.amazonaws.com"
  exit 1
fi

URL="http://${ALB_DNS}/hello"

echo "Generating load against: $URL"
echo "Press Ctrl+C to stop."

while true; do
  for i in {1..100}; do
    curl -s "$URL" >/dev/null &
  done
  sleep 1
done
