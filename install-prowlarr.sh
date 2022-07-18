#!/bin/bash

# Bash script for installing prowlarr on Alpine Linux

# Install dependencies
apk add -U --upgrade --no-cache \
    curl \
    jq \
    icu-libs \
    sqlite-libs

# Package variables
PKG_BRANCH=develop
PKG_VER=$(curl -sL "https://prowlarr.servarr.com/v1/update/${PKG_BRANCH}/changes?runtime=netcore&os=linuxmusl" | jq -r '.[0].version')
PKG_DIR="/opt/prowlarr"
PKG_CONF="/var/lib/prowlarr"
VERSION=$(echo $PKG_VER | cut -b 1-5)
# Userspace variables
username=prowlarr

# Create install folder
mkdir -p $PKG_DIR/bin
mkdir -p $PKG_CONF

# User management
adduser -u 1000 -H -D $username

# Download and install latest prowlarr release
  curl -L "https://prowlarr.servarr.com/v1/update/${PKG_BRANCH}/updatefile?version=${PKG_VER}&os=linuxmusl&runtime=netcore&arch=x64" -o /tmp/prowlarr.tar.gz  && \
  tar xzf \
    /tmp/prowlarr.tar.gz -C \
    $PKG_DIR/bin --strip-components=1

# Post install cleanup
  rm -rf \
    /tmp/prowlarr.tar.gz \
    $PKG_DIR/bin/Prowlarr.Update

# Create service
cat << EOF >> /etc/init.d/prowlarr
#!/sbin/openrc-run

name="prowlarr"
pidfile="/run/prowlarr.pid"
directory="$PKG_DIR/bin"
command="$PKG_DIR/bin/Prowlarr"
command_args="-nobrowser -data=$PKG_CONF"
command_background=true
command_user="$username"

depend() {
    need net
}
EOF

# Set permissions
chown $username:$username -R $PKG_DIR
chown $username:$username -R $PKG_CONF
chmod 755 /etc/init.d/prowlarr

# Add service
rc-update add prowlarr default
# Start server
rc-service prowlarr start

cat << EOF >> $PKG_DIR/package_info
# Do Not Edit
PackageVersion=$VERSION
PackageAuthor=[Team Prowlarr](https://prowlarr.com) & Alpine Linux install script by: [x-keita](https://github.com/x-keita/alpine-scripts)
ReleaseVersion=$PKG_VER
UpdateMethod=BuiltIn
Branch=$PKG_BRANCH
EOF

    cat << EOF
------------------------------------------------------------------------------------
Installed! Prowlarr runs on localhost:9696 by default. 
Also you can update directly from the application using the BuiltIn method and/or
change branch to develop without any issues.
------------------------------------------------------------------------------------
EOF
