#!/bin/bash

# Bash script for installing radarr on Alpine Linux

# Install dependencies
apk add -U --upgrade --no-cache \
  curl \
  jq \
  icu-libs \
  sqlite-libs

# Package variables
read -r -p "Which radarr branch do you want to install? <master/develop> " prompt
if [[ $prompt == "master" || $prompt == "Master" || $prompt == "MASTER" ]]
  then
    echo "Setting master as branch"
    PKG_BRANCH=master
  else
    echo "Setting develop as branch"
    PKG_BRANCH=develop
fi
PKG_VER=$(curl -sL "https://radarr.servarr.com/v1/update/${PKG_BRANCH}/changes?runtime=netcore&os=linuxmusl" | jq -r '.[0].version')
PKG_DIR="/opt/radarr"
PKG_CONF="/var/lib/radarr"
VERSION=$(echo $PKG_VER | cut -b 1-5)
# Userspace variables
username=radarr

# Create radarr install folders
mkdir -p $PKG_DIR/bin
mkdir -p $PKG_CONF

# User management
adduser -u 1000 -H -D $username

# Download and install latest radarr release
  curl -L "https://radarr.servarr.com/v1/update/${PKG_BRANCH}/updatefile?version=${PKG_VER}&os=linuxmusl&runtime=netcore&arch=x64" -o /tmp/radarr.tar.gz && \
  tar xzf \
    /tmp/radarr.tar.gz -C \
    $PKG_DIR/bin --strip-components=1

# Post install cleanup
  rm -rf \
    /tmp/radarr.tar.gz \
    $PKG_DIR/bin/Radarr.Update

# Create service
cat << EOF >> /etc/init.d/radarr
#!/sbin/openrc-run

name="radarr"
pidfile="/run/radarr.pid"
directory="$PKG_DIR/bin"
command="$PKG_DIR/bin/Radarr"
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
chmod 755 /etc/init.d/radarr

# Add service to start on boot
rc-update add radarr default
# Start server
rc-service radarr start

cat << EOF >> $PKG_DIR/package_info
# Do Not Edit
PackageVersion=$VERSION
PackageAuthor=[Team Radarr](https://radarr.video) & Alpine Linux install script by: [x-keita](https://github.com/x-keita/alpine-scripts)
ReleaseVersion=$PKG_VER
UpdateMethod=BuiltIn
Branch=$PKG_BRANCH
EOF

    cat << EOF
------------------------------------------------------------------------------------
Installed! Radarr runs on localhost:7878 by default. 
Also you can update directly from the application using the BuiltIn method and/or
change branch to develop without any issues.
------------------------------------------------------------------------------------
EOF
