#!/bin/bash

# function to list all stopped containers that do not have "data" in the name
# dependencies: socat, curl, jq (http://stedolan.github.io/jq/)
function stopped-non-data-containers() {
  # temporarily reverse proxy the docker daemon unix socket through TCP
  socat TCP-LISTEN:0,reuseaddr,fork UNIX-CLIENT:/var/run/docker.sock &
  SOCAT_PID=$!
  SOCAT_PORT=$(lsof -p $SOCAT_PID -a -i TCP -F 2>/dev/null | awk -F: '/^n\*:/ {print $2}')

  # output IDs of all stopped containers that do not have "data" in the name
  curl -sS http://localhost:$SOCAT_PORT/containers/json\?all=1 | jq --raw-output 'map(select(.Status | contains ("Exited"))) - map(select(.Names[] | contains ("data"))) | .[] .Id'

  # clean up the reverse proxy
  kill $SOCAT_PID
  wait $SOCAT_PID
}

function docker-gc() {
  if [ -n "$(stopped-non-data-containers)" ]; then
    echo "deleting stopped non-data containers:"
    docker rm $(stopped-non-data-containers)
  fi
  if [ -n "$(docker images -f "dangling=true" -q)" ]; then
    echo "deleting dangling images:"
    docker rmi $(docker images -f "dangling=true" -q)
  fi
}
