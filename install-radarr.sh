#!/bin/bash

# Bash script for installing radarr on Alpine Linux

# Install dependencies
apk update && apk add --no-cache \
  curl \
  jq \
  icu-libs \
  sqlite-libs

# Set variables
RADARR_DIR="/usr/lib/radarr"
RADARR_CONF="/var/lib/radarr"
BRANCH=master
PKG_INFO=$RADARR_DIR/package_info
PKG_VER=$(curl -sL "https://radarr.servarr.com/v1/update/${BRANCH}/changes?runtime=netcore&os=linuxmusl" | jq -r '.[0].version' | cut -b 1-5)
RELEASE_VERSION=$(curl -sL "https://radarr.servarr.com/v1/update/${BRANCH}/changes?runtime=netcore&os=linuxmusl" | jq -r '.[0].version')

# Create radarr install folders
mkdir -p $RADARR_DIR/bin
mkdir -p $RADARR_CONF

# Download and install latest
  curl -L  -L "https://radarr.servarr.com/v1/update/${BRANCH}/updatefile?version=${RELEASE_VERSION}&os=linuxmusl&runtime=netcore&arch=x64" -o /tmp/radarr.tar.gz && \
  tar xzf \
    /tmp/radarr.tar.gz -C \
    $RADARR_DIR/bin --strip-components=1

# Post install cleanup
  rm -rf \
    /tmp/radarr.tar.gz \
    $RADARR_DIR/bin/Radarr.Update

# Create service
curl -L https://raw.githubusercontent.com/x-keita/alpine-scripts/main/init.d/radarr -o /etc/init.d/radarr
chmod 755 /etc/init.d/radarr

# Add service to start on boot
rc-update add radarr default
# Start server
rc-service radarr start

cat <<  %%_PKG_INFO_%% > $PKG_INFO
# Do Not Edit
PackageVersion=$PKG_VER
PackageAuthor=[Team Radarr](https://radarr.video/) & Alpine Linux install script by: [x-keita](https://github.com/x-keita/alpine-scripts)
ReleaseVersion=$RELEASE_VERSION
UpdateMethod=builtIn
Branch=$BRANCH
%%_PKG_INFO_%%

# Script end text

    cat << EOF
------------------------------------------------------------------------------------
Installed! Radarr runs on localhost:7878 by default. 
Also you can update directly from the application using the BuiltIn method and/or
change branch to develop without any issues.
------------------------------------------------------------------------------------
EOF
