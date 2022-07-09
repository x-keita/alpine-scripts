#!/bin/bash

# Bash script for installing sonarr on Alpine Linux

# Install dependencies
apk update && apk add --no-cache \
  curl \
  jq \
  libmediainfo \
  sqlite-libs

apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  mono

# Set variables
SONARR_DIR="/usr/lib/sonarr"
SONARR_CONF="/var/lib/sonarr"
BRANCH=main
PKG_INFO=$SONARR__DIR/package_info
PKG_VER=$(curl -sX GET http://services.sonarr.tv/v1/releases | jq -r '.[] | select(.branch==\"$BRANCH\") | .version' | cut -b 1-5)
RELEASE_VERSION=$(curl -sX GET http://services.sonarr.tv/v1/releases | jq -r ".[] | select(.branch==\"$BRANCH\") | .version")

# Create sonarr install folders
mkdir -p $SONARR_DIR/bin
mkdir -p $SONARR_CONF

# Download and install latest
  curl -L  -L "https://download.sonarr.tv/v3/${BRANCH}/${RELEASE_VERSION}/Sonarr.main.${RELEASE_VERSION}.linux.tar.gz" -o /tmp/sonarr.tar.gz && \
  tar xzf \
    /tmp/sonarr.tar.gz -C \
    $SONARR_DIR/bin --strip-components=1

# Post install cleanup
  rm -rf \
    /tmp/sonarr.tar.gz \
    $SONARR_DIR/bin/Sonarr.Update

# Create service
curl -L https://raw.githubusercontent.com/x-keita/alpine-scripts/main/init.d/sonarr -o /etc/init.d/sonarr
chmod 755 /etc/init.d/sonarr

# Add service to start on boot
rc-update add sonarr default
# Start server
rc-service sonarr start

cat <<  %%_PKG_INFO_%% > $PKG_INFO
# Do Not Edit
PackageVersion=$PKG_VER
PackageAuthor=[Team Sonarr](https://sonarr.tv) & Alpine Linux install script by: [x-keita](https://github.com/x-keita/alpine-scripts)
ReleaseVersion=$RELEASE_VERSION
UpdateMethod=builtIn
Branch=$BRANCH
%%_PKG_INFO_%%

# Script end text

    cat << EOF
------------------------------------------------------------------------------------
Installed! Sonarr runs on localhost:8989 by default. 
Also you can update directly from the application using the BuiltIn method and/or
change branch to develop without any issues.
------------------------------------------------------------------------------------
EOF
