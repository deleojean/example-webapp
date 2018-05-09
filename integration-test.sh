#!/bin/bash

COUNTER=0
TARGET_URI=$1

while true; do
  STATUS=$(curl -s -o /dev/null -w '%{http_code}' $TARGET_URI)

  if [[ $STATUS -eq 200 ]]; then
    echo "Got 200 OK! All Done!"
    break
  elif [[ $COUNTER -ge 3 ]]; then
    # test failed
    exit 1
  fi

  echo "Got $STATUS Status Code..."
  sleep 10
  let COUNTER+=1
done
