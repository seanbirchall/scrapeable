#!/bin/bash
DEPLOY_DIR="/var/www/html/scrapeable"
BRANCH="main"

cd "$DEPLOY_DIR"
git pull origin "$BRANCH"
