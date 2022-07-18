#!/bin/bash

# Bash script for installing sonarr on Alpine Linux

# Install dependencies
apk add -U --upgrade --no-cache \
  curl \
  jq \
  libmediainfo \
  sqlite-libs
apk add -U --upgrade --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  mono

# Package variables
read -r -p "Which sonarr branch do you want to install? <main/develop> " prompt
if [[ $prompt == "main" || $prompt == "Main" || $prompt == "MAIN" ]]
  then
    echo "Setting main as branch"
    PKG_BRANCH=main
  else
    echo "Setting develop as branch"
    PKG_BRANCH=develop
fi
PKG_VER=$(curl -sX GET http://services.sonarr.tv/v1/releases | jq -r ".[] | select(.branch==\"$PKG_BRANCH\") | .version")
PKG_DIR="/opt/sonarr"
PKG_CONF="/var/lib/sonarr"
VERSION=$(echo $PKG_VER | cut -b 1-5)
# Userspace variables
username=sonarr

# Create sonarr install folders
mkdir -p $PKG_DIR/bin
mkdir -p $PKG_CONF

# User management
adduser -u 1000 -H -D $username

# Download and install latest sonarr release
  curl -L "https://download.sonarr.tv/v3/${PKG_BRANCH}/${PKG_VER}/Sonarr.main.${PKG_VER}.linux.tar.gz" -o /tmp/sonarr.tar.gz && \
  tar xzf \
    /tmp/sonarr.tar.gz -C \
    $PKG_DIR/bin --strip-components=1

# Post install cleanup
  rm -rf \
    /tmp/sonarr.tar.gz \
    $PKG_DIR/bin/Sonarr.Update

# Create service
cat << EOF >> /etc/init.d/sonarr
#!/sbin/openrc-run

name="sonarr"
pidfile="/run/sonarr.pid"
directory="$PKG_DIR/bin"
command="/usr/bin/mono"
command_args="--debug Sonarr.exe -nobrowser -data=$PKG_CONF"
command_background=true
command_user="$username"

depend() {
    need net
}
EOF

# Set permissions
chown $username:$username -R $PKG_DIR
chown $username:$username -R $PKG_CONF
chmod 755 /etc/init.d/sonarr

# Add service to start on boot
rc-update add sonarr default
# Start server
rc-service sonarr start

cat << EOF >> $PKG_DIR/package_info
# Do Not Edit
PackageVersion=$VERSION
PackageAuthor=[Team Sonarr](https://sonarr.tv) & Alpine Linux install script by: [x-keita](https://github.com/x-keita/alpine-scripts)
ReleaseVersion=$PKG_VER
UpdateMethod=BuiltIn
Branch=$PKG_BRANCH
EOF

# Add mono certs
cert-sync /etc/ssl/certs/ca-certificates.crt

    cat << EOF
------------------------------------------------------------------------------------
Installed! Sonarr runs on localhost:8989 by default. 
Also you can update directly from the application using the BuiltIn method and/or
change branch to develop without any issues.
------------------------------------------------------------------------------------
EOF
