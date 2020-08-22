#!/usr/bin/env sh

if [ ! -d "/opt/octoprint" ]; then
  echo "Extracting octoprint"
  tar x /opt/octoprint.tar.gz -C /opt
fi

exec "$@"
