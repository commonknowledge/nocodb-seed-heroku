#!/bin/sh
set -e

REPO_DIR="/usr/app/data/repo"
DB_SRC="/usr/app/data/noco.db"
DB_DEST="$REPO_DIR/nocodb.sqlite"
NC_SRC_DIR="/usr/app/data/nc"
NC_DEST_DIR="$REPO_DIR/nc"

# Function to attempt git push with retries
attempt_push() {
  local branch_name="$1"
  local retry_count=5
  local delay=1
  echo "[sync] Attempting to push changes for $branch_name..."
  for i in $(seq 1 $retry_count); do
    if git push origin "$branch_name"; then
      echo "[sync] Git push successful for $branch_name."
      return 0
    else
      echo "[sync] Push failed for $branch_name. Retry $i/$retry_count..."
      sleep "$delay"
      delay=$(($delay * 2))
    fi
  done
  echo "[sync] Failed to push $branch_name after $retry_count retries."
  return 1
}

while true; do
  sleep 30  # every 30 seconds

  echo "[sync] Beginning sync operation cycle"

  echo "[sync-db] Checking for database changes..."
  if ! cmp -s "$DB_SRC" "$DB_DEST"; then
    echo "[sync-db] Database changed. Syncing to Git..."
    cp "$DB_SRC" "$DB_DEST"
    cd "$REPO_DIR"
    git config user.name "SQLite Sync Bot"
    git config user.email "hello@commonknowledge.coop"
    git add nocodb.sqlite
    if git commit -m "Automated SQLite database sync: $(date +%Y-%m-%dT%H:%M:%S)"; then
      attempt_push "main"
    else
      echo "[sync-db] No changes to commit for database or commit failed."
    fi
  else
    echo "[sync-db] No database changes detected."
  fi

  echo "[sync-images] Checking for 'nc' directory changes..."
  
  mkdir -p "$NC_DEST_DIR"

  # -a for archive, -v for verbose, --progress for transfer progress, --delete to remove extraneous files from destination
  rsync -av --progress --delete "$NC_SRC_DIR/" "$NC_DEST_DIR/"

  cd "$REPO_DIR"

  if [ -n "$(git status --porcelain "$NC_DEST_DIR")" ]; then
    echo "[sync-images] 'nc' directory changed. Syncing to Git..."
    git config user.name "Images Sync Bot"
    git config user.email "hello@commonknowledge.coop"
    git add "$NC_DEST_DIR"
    if git commit -m "Automated directory sync: $(date +%Y-%m-%dT%H:%M:%S)"; then
      attempt_push "main" 
    else
      echo "[sync-images] No changes to commit for 'nc' directory or commit failed."
    fi
  else
    echo "[sync-images] No 'nc' directory changes detected."
  fi

  echo "[sync] Sync operation cycle finished."
done
