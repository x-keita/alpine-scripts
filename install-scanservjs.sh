#!/bin/bash

# Bash script for installing scanservjs & sane on Alpine

url=$(curl -s https://api.github.com/repos/sbs20/scanservjs/releases/latest | grep browser_download_url | cut -d '"' -f 4)

# Install required packages and dependencies
apk update && apk add --no-cache \
  npm \
  imagemagick \
  sane-utils \
  sane-udev \
  sane-backends \
  tesseract-ocr

# Create install folder
mkdir -p /var/www/scanservjs
# Download latest scanservjs release
curl -L $url | tar -zxf - -C /var/www/scanservjs/

# Imagemagick edits
# Enable pdf and avoid out of memory issues with large or multiple scans
  sed -i \
    's/policy domain="coder" rights="none" pattern="PDF"/policy domain="coder" rights="read | write" pattern="PDF"'/ \
    /etc/ImageMagick-7/policy.xml \
  && sed -i \
    's/policy domain="resource" name="disk" value="1GiB"/policy domain="resource" name="disk" value="8GiB"'/ \
    /etc/ImageMagick-7/policy.xml

# Install npm dependencies
npm install -g npm@8.3.0
cd /var/www/scanservjs/ && npm install --only=production

# Create service
curl -L https://raw.githubusercontent.com/x-keita/alpine-scripts/main/init.d/scanservjs -o /etc/init.d/scanservjs
chmod 755 /etc/init.d/scanservjs
# Add service
rc-update add scanservjs default
# Start server
rc-service scanservjs start

    cat << EOF

------------------------------------------------------------------------------------
Installed! By default scanservjs runs on port 8080, if you have any issues you can
change the port by editing /var/www/scanservjs/server/config.js @ Line 17

Also, by default files are saved into /var/www/scanservjs/data/output you can change
this by editing /var/www/scanservjs/server/config.js @ Line 47
------------------------------------------------------------------------------------

EOF
