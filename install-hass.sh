#!/bin/bash

# Bash script for installing Home Assistant on Alpine Linux

# Install build-dependencies for HASS
apk add --no-cache --virtual=build-dependencies \
  autoconf \
  ca-certificates \
  cargo \
  cmake \
  cups-dev \
  eudev-dev \
  ffmpeg-dev \
  gcc \
  glib-dev \
  g++ \
  jq \
  libffi-dev \
  jpeg-dev \
  libxml2-dev \
  libxslt-dev \
  make \
  postgresql-dev \
  python3-dev \
  unixodbc-dev \
  unzip

# Install HASS dependencies
apk add -U --upgrade --no-cache \
  bluez \
  bluez-deprecated \
  bluez-libs \
  cups-libs \
  curl \
  eudev-libs \
  ffmpeg \
  iputils \
  libcap \
  libpcap \
  libjpeg-turbo \
  libstdc++ \
  libxslt \
  mariadb-connector-c \
  mariadb-connector-c-dev \
  openssh-client \
  openssl \
  postgresql-libs \
  py3-pip \
  python3 \
  tiff

# Package variables variables
PKG_VER=$(curl -sX GET https://api.github.com/repos/home-assistant/core/releases/latest | jq -r .tag_name)
PKG_CONF="/var/lib/hass"
PIP_CMD="--no-cache-dir --use-deprecated=legacy-resolver"
# Userspace variables
username=homeassistant
uid=1000

# Create hass install folders
mkdir -p $PKG_CONF

# User management
adduser -u $uid -D $username

# Download latest release source
mkdir -p /tmp/core
curl -L "https://github.com/home-assistant/core/archive/${PKG_VER}.tar.gz" -o /tmp/core.tar.gz  && \
  tar xf \
    /tmp/core.tar.gz -C \
    /tmp/core --strip-components=1

# Install HASS and components
cd /tmp/core
## Build pre-requisites
pip install --no-cache-dir --upgrade \
    cython \
    "pip>=21.0,<22.2" \
    setuptools \
    wheel
# Build HASS Components
pip install ${PIP_CMD} -r requirements_all.txt
pip install ${PIP_CMD} pycups
# Install latest HomeAssistant
pip install ${PIP_CMD} homeassistant==${PKG_VER}

# Set custom install status
sed -i "s|Unknown|Home Assistant Core (Unofficial Dockerless installation)|" /usr/lib/python3.10/site-packages/homeassistant/helpers/system_info.py

# Post-install cleanup
  apk del --purge \
    build-dependencies && \
  for cleanfiles in *.pyc *.pyo; \
    do \
    find /usr/lib/python3.*  -iname "${cleanfiles}" -exec rm -f '{}' + \
    ; done && \
  rm -rf \
    /tmp/core.tar.gz \
    /tmp/core \
    /usr/LICENSE \
    /usr/requirements.txt \
    /root/.cache \
    /usr/config

# Create service
cat << EOF >> /etc/init.d/hass-core
#!/sbin/openrc-run

name="home-assistant-core"
supervisor="supervise-daemon"
pidfile="/run/hass-core.pid"
command="/usr/bin/hass"
command_args="-c $PKG_CONF"
command_background=true

depend() {
    need net
}
start_pre() {
  setcap 'cap_net_bind_service=+ep' /usr/bin/python3.10
}
EOF

# Set permissions
chown $username:$username -R $PKG_CONF
chmod 755 /etc/init.d/hass-core

# Add service to start on boot
rc-update add hass-core default
# Start server
rc-service hass-core start

    cat << EOF
------------------------------------------------------------------------------------
Installed! HomeAssistant runs on localhost:8123 by default. 
You can update HASS version using pip3 install --upgrade homeassistant
------------------------------------------------------------------------------------
EOF
