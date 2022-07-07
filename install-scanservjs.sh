#!/bin/bash

# Bash script for installing scanservjs & sane on Alpine
# Usage:
#   curl -s https://github.com/x-keita/alpine-scripts/raw/main/install-scanservjs.sh | sudo bash -s --

url=$(curl -s https://api.github.com/repos/sbs20/scanservjs/releases/latest | grep browser_download_url | cut -d '"' -f 4)

# Install required packages and dependencies
apk update && apk add --no-cache \
  npm \
  imagemagick \
  sane-utils \
  sane-udev \
  sane-backends \
  tesseract-ocr

# Download latest scanservjs release
curl -L $url | tar -zxf - -C /var/www/scanservjs/

# Imagemagick edits
# Enable pdf
sed -i 's/policy domain="coder" rights="none" pattern="PDF"/policy domain="coder" rights="read | write" pattern="PDF"' /etc/ImageMagick-7/policy.xml
# Avoid out of memory issues with large or multiple scans
sed -i 's/policy domain="resource" name="disk" value="1GiB"/policy domain="resource" name="disk" value="8GiB"' /etc/ImageMagick-7/policy.xml

# Install npm dependencies
npm install -g npm@7.11.2

cd /var/www/scanservjs/ && npm install --production

node ./server/server.js
