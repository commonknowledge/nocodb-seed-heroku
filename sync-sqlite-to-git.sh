#!/bin/sh
set -e

REPO_DIR="/usr/src/appEntry/repo"
DB_SRC="/usr/app/data/nocodb.sqlite"
DB_DEST="$REPO_DIR/data/nocodb.sqlite"
MAX_RETRIES=5

#mkdir -p "$REPO_DIR/data"

while true; do
  sleep 10  # every 10 seconds

  echo "[sync] Beginning sync operation"

  if ! cmp -s "$DB_SRC" "$DB_DEST"; then
    echo "[sync] Database changed. Syncing to Git..."
  else
    echo "[sync] No database changes detected."
  fi

# Comment everything out, let's just get this going for now
#     cp "$DB_SRC" "$DB_DEST"

#     cd "$REPO_DIR"
#     git config user.name "SQLite Sync Bot"
#     git config user.email "sync@yourdomain.com"
#     git add data/nocodb.sqlite

#     if git commit -m "Automated DB sync: $(date +%Y-%m-%dT%H:%M:%S)"; then
#       for i in 1 2 3 4 5; do
#         if git push origin main; then
#           echo "[sync] Git push successful."
#           break
#         else
#           echo "[sync] Push failed. Retry $i/5..."
#           sleep $((2 ** i))
#         fi
#       done
#     else
#       echo "[sync] Nothing to commit."
#     fi
#   else
#     echo "[sync] No DB changes detected."
#   fi
done
