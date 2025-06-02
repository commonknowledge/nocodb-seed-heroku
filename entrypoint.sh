#!/bin/sh
set -e

# Set up Git SSH
if [ -n "$GITHUB_DEPLOY_KEY_PRIVATE" ]; then
  mkdir -p ~/.ssh
  echo "$GITHUB_DEPLOY_KEY_PRIVATE" > ~/.ssh/id_rsa
  chmod 600 ~/.ssh/id_rsa
  ssh-keyscan github.com >> ~/.ssh/known_hosts
fi

# Clone the repo if it doesn't exist
if [ ! -d "/usr/src/appEntry/repo/.git" ]; then
  echo "[entrypoint] Cloning Git repo..."
  git clone git@github.com:commonknowledge/community-climate-justice-archive.git /usr/src/appEntry/repo
fi

# Start sync in background
/usr/src/appEntry/sync-sqlite-to-git.sh &

# Start NocoDB
exec sh /usr/src/appEntry/start.sh