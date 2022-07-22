#!/bin/bash

# Bash script for installing qbittorrent-nox on Alpine Linux

apk add -U --upgrade --no-cache \
  qbittorrent-nox

# User management
deluser qbittorrent
adduser -u 1000 -D -H qbittorrent

# Add service to start on boot
rc-update add qbittorrent-nox default
# Start server
rc-service qbittorrent-nox start

    cat << EOF
------------------------------------------------------------------------------------
Installed! qbittorrent-nox localhost:8080 by default.
The default WebUI user:password is admin:adminadmin
------------------------------------------------------------------------------------
EOF
