#!/bin/bash
# Ensure script runs as the sean user
if [ "$(whoami)" != "sean" ]; then
  sudo -u sean "$0" "$@"
  exit
fi

DEPLOY_DIR="/var/www/html/scrapeable"
BRANCH="main"
cd "$DEPLOY_DIR"
git fetch origin "$BRANCH"
git reset --hard "origin/$BRANCH"
