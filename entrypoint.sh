#!/bin/sh
set -e

# Start sync in background
/usr/src/appEntry/sync-db-to-git.sh &

# Start NocoDB
exec sh /usr/src/appEntry/start.sh