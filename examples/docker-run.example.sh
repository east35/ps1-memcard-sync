#!/usr/bin/env sh
# Example: PS1 save sync with docker run

docker run -d \
  --name ps1-memcard-sync \
  --restart unless-stopped \
  -e PUID=1026 \            # replace with your UID (id <user>)
  -e PGID=100 \             # replace with your GID
  -e WATCH_DIR=/watch \
  -e POLL_INTERVAL=2 \
  -v /volume1/MiSTer/saves/PSX:/watch:rw \
  ghcr.io/<youruser>/ps1-memcard-sync:latest