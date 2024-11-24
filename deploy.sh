#!/bin/bash
sudo -u sean bash << 'EOF'
DEPLOY_DIR="/var/www/html/scrapeable"
BRANCH="main"
cd "$DEPLOY_DIR"
git fetch origin "$BRANCH"
git reset --hard "origin/$BRANCH"
EOF
