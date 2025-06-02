#!/bin/sh
set -e

REPO_DIR="/usr/src/appEntry/repo"
DB_SRC="/usr/app/data/noco.db"
DB_DEST="$REPO_DIR/nocodb.sqlite"

while true; do
  sleep 30  # every 30 seconds

  echo "[sync] Beginning sync operation"

  if ! cmp -s "$DB_SRC" "$DB_DEST"; then
    echo "[sync] Database changed. Syncing to Git..."
  else
    echo "[sync] No database changes detected."
  fi

  cp "$DB_SRC" "$DB_DEST"

  cd "$REPO_DIR"
  git config user.name "SQLite Sync Bot"
  git config user.email "hello@commonknowledge.coop"
  git add nocodb.sqlite

  if git commit -m "Automated SQLite database sync: $(date +%Y-%m-%dT%H:%M:%S)"; then
    delay=1
    for i in 1 2 3 4 5; do
      if git push origin main; then
        echo "[sync] Git push successful."
        break
      else
        echo "[sync] Push failed. Retry $i/5..."
        sleep "$delay"
        delay=$(($delay * 2))
      fi
    done
  else
    echo "[sync] Nothing to commit."
  fi
done
