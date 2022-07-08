#!/bin/bash

# Bash script for installing sonarr 

# Install required packages and dependencies
apk update && apk add --no-cache \
  curl \
  jq \
  libmediainfo \
  sqlite-libs

# Fetch mono from testing branch
apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  mono

# Create sonarr install folders
mkdir -p /usr/lib/sonarr/bin
mkdir -p /var/lib/sonarr

# Download sonarr
  if [ -z ${SONARR_VERSION+x} ]; then \
    SONARR_VERSION=$(curl -sX GET http://services.sonarr.tv/v1/releases | jq -r ".[] | select(.branch==\"main\") | .version"); \
  fi && \
  curl -o \
    /tmp/sonarr.tar.gz -L \
    "https://download.sonarr.tv/v3/main/${SONARR_VERSION}/Sonarr.main.${SONARR_VERSION}.linux.tar.gz" && \
  tar xzf \
    /tmp/sonarr.tar.gz -C \
    /usr/lib/sonarr/bin --strip-components=1

# Remove integrated update service since we can't use it
rm -rf /usr/lib/sonarr/bin/Sonarr.Update && \

# Post install cleanup
rm -rf /tmp/sonarr.tar.gz

# Run with 
# cd /usr/lib/sonarr/bin
# mono --debug Sonarr.exe -nobrowser -data=/var/lib/sonarr
# Missing: Custom update script, start as a service
