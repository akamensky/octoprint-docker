#!/usr/bin/env sh

if [ ! -d "/opt/octoprint/bin" ]; then
  echo "Extracting octoprint"
  tar -xf /opt/octoprint.tar.gz --strip-components=1 -C /opt/octoprint
fi

chown -R octoprint:octoprint /opt/octoprint

exec "$@"
