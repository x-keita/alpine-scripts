#!/bin/bash

# Bash script for installing sonarr on Alpine Linux

sonarr_dir="/usr/lib/sonarr"
sonarr_conf="/var/lib/sonarr"

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
mkdir -p $sonarr_dir/bin
mkdir -p $sonarr_conf

# Download sonarr
  if [ -z ${SONARR_VERSION+x} ]; then \
    SONARR_VERSION=$(curl -sX GET http://services.sonarr.tv/v1/releases | jq -r ".[] | select(.branch==\"main\") | .version"); \
  fi && \
  curl -o \
    /tmp/sonarr.tar.gz -L \
    "https://download.sonarr.tv/v3/main/${SONARR_VERSION}/Sonarr.main.${SONARR_VERSION}.linux.tar.gz" && \
  tar xzf \
    /tmp/sonarr.tar.gz -C \
    $sonarr_dir/bin --strip-components=1

# Post install cleanup
rm -rf \
  /tmp/sonarr.tar.gz \
  $sonarr_dir/bin/Sonarr.Update

# Create service
curl -L https://raw.githubusercontent.com/x-keita/alpine-scripts/main/init.d/sonarr -o /etc/init.d/sonarr
chmod 755 /etc/init.d/sonarr

# Add service
rc-update add sonarr default
# Start server
rc-service sonarr start

# Set version variables
info="$sonarr_dir/package_info"
package_ver=$(curl -sX GET http://services.sonarr.tv/v1/releases | jq -r '.[] | select(.branch=="main") | .version' | cut -b 1-5)

cat <<  %%_INFO_%% > $info
# Do Not Edit
PackageVersion=$package_ver
PackageAuthor=[Team Sonarr](https://sonarr.tv) & Alpine script by: [x-keita](https://github.com/x-keita/alpine-scripts)
ReleaseVersion=$SONARR_VERSION
UpdateMethod=builtIn
Branch=main
%%_INFO_%%

exit 0
