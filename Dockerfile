FROM nocodb/nocodb:latest

# A new entrypoint script that wraps the existing NocoDB entrypoint script, but also runs our sync
COPY entrypoint.sh /usr/src/appEntry/entrypoint.sh

# Add SQLite syncing script
COPY sync-sqlite-to-git.sh /usr/src/appEntry/sync-sqlite-to-git.sh
RUN chmod +x /usr/src/appEntry/*.sh

# Start NocoDB and our sync background worker
ENTRYPOINT ["sh", "/usr/src/appEntry/entrypoint.sh"]