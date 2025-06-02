FROM nocodb/nocodb:latest

# Add Git to the container and cleanup Apt temporary files
RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*


# Add rsync to the container and cleanup Apt temporary files
RUN apt-get update && \
    apt-get install -y rsync && \
    rm -rf /var/lib/apt/lists/*

# A new entrypoint script that wraps the existing NocoDB entrypoint script, but also runs our sync
COPY entrypoint.sh /usr/src/appEntry/entrypoint.sh

# Add SQLite syncing script
COPY sync-sqlite-to-git.sh /usr/src/appEntry/sync-sqlite-to-git.sh
RUN chmod +x /usr/src/appEntry/*.sh

# Start NocoDB and our sync background worker
ENTRYPOINT ["sh", "/usr/src/appEntry/entrypoint.sh"]