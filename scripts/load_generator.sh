#!/bin/bash

ALB_DNS="$1"

if [ -z "$ALB_DNS" ]; then
  echo "Usage: $0 <alb-dns-name>"
  echo "Example: $0 tech-eazy-app-lb-123456.ap-south-1.elb.amazonaws.com"
  exit 1
fi

URL="http://${ALB_DNS}/hello"

echo "=============================="
echo "  TechEazy Load Generator"
echo "  Target: $URL"
echo "  Press CTRL+C to stop"
echo "=============================="

# Heavy load loop
while true; do
  
  # Very high request burst
  for i in {1..15000}; do
    curl -s "$URL" >/dev/null &
  done

  # Add a second burst for stability
  for j in {1..15000}; do
    curl -s "$URL" >/dev/null &
  done

  # Short pause to avoid killing the instance itself
  sleep 0.2

done
