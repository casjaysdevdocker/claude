#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202601221300-git
# @@Author           :  CasjaysDev
# @@Contact          :  CasjaysDev <docker-admin@casjaysdev.pro>
# @@License          :  MIT
# @@Copyright        :  Copyright 2026 CasjaysDev
# @@Created          :  Wed Jan 22 01:00:00 PM EST 2026
# @@File             :  01-dockerd.sh
# @@Description      :  Init script to start Docker daemon (optional)
# @@Changelog        :  newScript
# @@TODO             :  Better documentation
# @@Other            :
# @@Resource         :
# @@Terminal App     :  no
# @@sudo/root        :  yes
# - - - - - - - - - - - - - - - - - - - - - - - - -
# shellcheck disable=SC1001,SC1003,SC2001,SC2003,SC2016,SC2031,SC2090,SC2115,SC2120,SC2155,SC2199,SC2229,SC2317,SC2329
# - - - - - - - - - - - - - - - - - - - - - - - - -
SCRIPT_NAME="$(basename "$0" 2>/dev/null)"
SCRIPT_PID_FILE="/run/init.d/$SCRIPT_NAME.pid"
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Set env/config variables
DOCKER_SOCKET="${DOCKER_SOCKET:-}"
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Check if Docker socket is already available from host
if [ -S "/var/run/docker.sock" ]; then
  # Check if it's actually writable (not just mounted)
  if docker info >/dev/null 2>&1; then
    echo "Using existing Docker daemon from host socket"
    exit 0
  fi
fi
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Ensure we're running with proper privileges for DinD
if [ ! -w "/var/run" ]; then
  echo "ERROR: Cannot start Docker-in-Docker daemon - insufficient privileges"
  echo "This container requires --privileged flag for full Docker-in-Docker support"
  echo "Example: docker run --privileged ..."
  exit 1
fi
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Create required directories for Docker
mkdir -p /var/lib/docker 2>/dev/null || true
mkdir -p /var/run 2>/dev/null || true
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Check if Docker daemon is already running
if [ -f "/var/run/docker.pid" ]; then
  pid=$(cat /var/run/docker.pid)
  if kill -0 "$pid" 2>/dev/null; then
    echo "Docker daemon is already running (PID: $pid)"
    exit 0
  fi
fi
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Write PID file
echo $$ >"$SCRIPT_PID_FILE"
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Start Docker daemon in DinD mode
echo "Starting Docker-in-Docker (DinD) daemon..."
echo "Full Docker environment initializing..."
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Start dockerd in the background
dockerd \
  --host=unix:///var/run/docker.sock \
  --storage-driver=vfs \
  >/data/logs/dockerd.log 2>&1 &

DOCKERD_PID=$!
echo "$DOCKERD_PID" > /var/run/docker.pid
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Wait for Docker daemon to be ready
echo "Waiting for Docker daemon to be ready..."
for i in {1..30}; do
  if docker info >/dev/null 2>&1; then
    echo "Docker daemon is ready (PID: $DOCKERD_PID)"
    exit 0
  fi
  sleep 1
done
# - - - - - - - - - - - - - - - - - - - - - - - - -
echo "ERROR: Docker daemon failed to start within 30 seconds"
exit 1
# - - - - - - - - - - - - - - - - - - - - - - - - -
# ex: ts=2 sw=2 et filetype=sh
