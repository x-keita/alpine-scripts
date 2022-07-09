#!/bin/bash

# Bash script for installing prowlarr on Alpine Linux

# Install dependencies
  apk add --no-cache \
    curl \
    jq \
    icu-libs \
    sqlite-libs

# Set variables
PROWLARR_DIR="/usr/lib/prowlarr"
PROWLARR_CONF="/var/lib/prowlarr"
BRANCH=develop
PKG_INFO=$PROWLARR_DIR/package_info
PKG_VER=$(curl -sL "https://prowlarr.servarr.com/v1/update/${BRANCH}/changes?runtime=netcore&os=linuxmusl" | jq -r '.[0].version' | cut -b 1-5)
RELEASE_VERSION=$(curl -sL "https://prowlarr.servarr.com/v1/update/${BRANCH}/changes?runtime=netcore&os=linuxmusl" | jq -r '.[0].version')

# Create directories
mkdir -p $PROWLARR_DIR/bin
mkdir -p $PROWLARR_CONF

# Download and install latest
  curl -L "https://prowlarr.servarr.com/v1/update/${BRANCH}/updatefile?version=${RELEASE_VERSION}&os=linuxmusl&runtime=netcore&arch=x64" -o /tmp/prowlarr.tar.gz  && \
  tar xzf \
    /tmp/prowlarr.tar.gz -C \
    $PROWLARR_DIR/bin --strip-components=1

# Post install cleanup
  rm -rf \
    /tmp/prowlarr.tar.gz \
    $PROWLARR_DIR/bin/Prowlarr.Update

# Create service
curl -L https://raw.githubusercontent.com/x-keita/alpine-scripts/main/init.d/prowlarr -o /etc/init.d/prowlarr
chmod 755 /etc/init.d/prowlarr

# Add service to start on boot
rc-update add prowlarr default
# Start server
rc-service prowlarr start

cat <<  %%_PKG_INFO_%% > $PKG_INFO
# Do Not Edit
PackageVersion=$PKG_VER
PackageAuthor=[Team Prowlarr](https://prowlarr.com/) & Alpine Linux install script by: [x-keita](https://github.com/x-keita/alpine-scripts)
ReleaseVersion=$RELEASE_VERSION
UpdateMethod=builtIn
Branch=$BRANCH
%%_PKG_INFO_%%

# Script end text

    cat << EOF
------------------------------------------------------------------------------------
Installed! Prowlarr runs on localhost:9696 by default. 
Also you can update directly from the application using the BuiltIn method and/or
change branch to develop without any issues.
------------------------------------------------------------------------------------
EOF
