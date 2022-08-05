#!/bin/bash

# Bash script for installing bazarr on Alpine Linux

# Install build-dependencies for Bazarr
apk add --no-cache --virtual=build-dependencies \
  build-base \
  cargo \
  g++ \
  gcc \
  jq \
  libffi-dev \
  libxml2-dev \
  libxslt-dev \
  python3-dev

# Install bazarr dependencies
apk add -U --upgrade --no-cache \
  curl \
  ffmpeg \
  libxml2 \
  libxslt \
  py3-pip \
  python3 \
  unzip
# Back-install unrar from older Alpine branch
apk add -U --upgrade --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.14/main \
  unrar

# Package variables
read -r -p "Which bazarr branch do you want to install? <stable/development> " prompt
if [[ $prompt == "stable" || $prompt == "Stable" || $prompt == "STABLE" ]]
  then
    echo "Setting stable/latest as branch"
    PKG_BRANCH=master
    PKG_VER=$(curl -sX GET "https://api.github.com/repos/morpheus65535/bazarr/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]')
  else
    echo "Setting development as branch"
    PKG_BRANCH=development
    PKG_VER=$(curl -sX GET https://api.github.com/repos/morpheus65535/bazarr/releases | jq -r '.[0] | .tag_name')
fi
PKG_DIR="/opt/bazarr"
PKG_CONF="/var/lib/bazarr"
VERSION=$(echo $PKG_VER | cut -b 1-5)
PIP_CMD="--no-cache-dir"
# Userspace variables
username=bazarr

# Setup Timezone
read -r -p "Bazarr requires to have timezone configured, have you already done that? <yes/no> " prompt
if [[ $prompt == "yes" || $prompt == "Yes" || $prompt == "YES" ]]
  then
    echo "Skipping, if you got this by error, you can run setup-timezone to configure it and then restart the bazarr service"
    wait 5
  else
    echo "Starting timezone configuration..."
    setup-timezone
fi

# Create bazarr install folders
mkdir -p $PKG_DIR/bin
mkdir -p $PKG_CONF

# User management
adduser -u 1000 -H -D $username

# Download and install latest bazarr release
  curl -L "https://github.com/morpheus65535/bazarr/releases/download/${PKG_VER}/bazarr.zip" -o /tmp/bazarr.zip && \
  unzip \
    /tmp/bazarr.zip -d \
    $PKG_DIR/bin

# Install Bazarr components
cd $PKG_DIR/bin
# Build pre-requisites
pip install --no-cache-dir --upgrade \
  wheel
# Build Bazarr components
pip install ${PIP_CMD} -r requirements.txt

# Post install cleanup
apk del --purge \
  build-dependencies

rm -rf \
  /tmp/bazarr.zip \
  /root/.cache

# Create service
cat << EOF >> /etc/init.d/bazarr
#!/sbin/openrc-run

name="bazarr"
pidfile="/run/bazarr.pid"
directory="$PKG_DIR/bin"
command="python3 $PKG_DIR/bin/bazarr.py"
command_args="--config $PKG_CONF"
command_background=true
command_user="$username"

depend() {
    need net
}
EOF

# Set permissions
chown $username:$username -R $PKG_DIR
chown $username:$username -R $PKG_CONF
chmod 755 /etc/init.d/bazarr

# Add service to start on boot
rc-update add bazarr default
# Start server
rc-service bazarr start

cat << EOF >> $PKG_DIR/package_info
# Do Not Edit
PackageVersion=$VERSION
PackageAuthor=Team bazarr - https://bazarr.media & Alpine Linux install script by: x-keita - https://github.com/x-keita/alpine-scripts
ReleaseVersion=$PKG_VER
UpdateMethod=BuiltIn
Branch=$PKG_BRANCH
EOF

    cat << EOF
------------------------------------------------------------------------------------
Installed! bazarr runs on localhost:6767 by default. 
Also you can update directly from the application using the BuiltIn method and/or
change branch to develop without any issues.
------------------------------------------------------------------------------------
EOF
