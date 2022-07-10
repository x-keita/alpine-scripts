#!/bin/bash

# Bash script for installing Home Assistant on Alpine Linux
# Based on linuxserver.io Dockerfile
# https://github.com/linuxserver/docker-homeassistant

# Temporarily install packages needed for building HASS
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
  apk add --no-cache \
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

# Set variables
PIPFLAGS="--no-cache-dir --use-deprecated=legacy-resolver --find-links https://wheel-index.linuxserver.io/alpine-3.16/ --find-links https://wheel-index.linuxserver.io/homeassistant-3.16/"
PYTHONPATH="${PYTHONPATH}:/pip-packages"
RELEASE_VERSION=$(curl -sX GET https://api.github.com/repos/home-assistant/core/releases/latest | jq -r .tag_name)

# Create directories
mkdir -p /tmp/core
mkdir -p /var/lib/hass

# Download latest release source
#curl -L "https://github.com/home-assistant/core/archive/${RELEASE_VERSION}.tar.gz" -o /tmp/core.tar.gz  && \
curl -L "https://github.com/home-assistant/core/archive/2022.7.0.tar.gz" -o /tmp/core.tar.gz  && \
  tar xf \
    /tmp/core.tar.gz -C \
    /tmp/core --strip-components=1

# Set install arch
HASS_BASE=$(cat /tmp/core/build.yaml | grep 'amd64: ' | cut -d: -f3)

# Install HASS and required site packages
mkdir -p /pip-packages

  pip install --target /pip-packages --no-cache-dir --upgrade \
    distlib && \
  pip install --no-cache-dir --upgrade \
    cython \
    "pip>=21.0,<22.1" \
    setuptools \
    wheel

cd /tmp/core && \
  NUMPY_VER=$(grep "numpy" requirements_all.txt) && \
  pip install ${PIPFLAGS} \
    "${NUMPY_VER}" && \
  pip install ${PIPFLAGS} \
    -r https://raw.githubusercontent.com/home-assistant/docker/${HASS_BASE}/requirements.txt && \
  pip install ${PIPFLAGS} \
    -r requirements_all.txt && \
  pip install ${PIPFLAGS} \
    homeassistant==${RELEASE_VERSION} && \
  pip install ${PIPFLAGS} \
    pycups \
    PySwitchbot

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
    /root/.cargo \
    /usr/config

# Create service
curl -L https://raw.githubusercontent.com/x-keita/alpine-scripts/main/init.d/hass -o /etc/init.d/hass
chmod 755 /etc/init.d/hass

# Add service to start on boot
rc-update add hass default
# Start server
rc-service hass start

# Script end text

    cat << EOF
------------------------------------------------------------------------------------
Installed! HomeAssistant runs on localhost:8123 by default. 
------------------------------------------------------------------------------------
EOF
