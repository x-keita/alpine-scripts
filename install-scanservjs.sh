#!/bin/bash

# Bash script for installing scanservjs & sane on Alpine

# Install required packages and dependencies
apk add -U --upgrade --no-cache \
  curl \
  npm \
  imagemagick \
  sane-utils \
  sane-udev \
  sane-backends \
  tesseract-ocr

# Package variables
PKG_URL=$(curl -s https://api.github.com/repos/sbs20/scanservjs/releases/latest | grep browser_download_url | cut -d '"' -f 4)
PKG_DIR="/var/www/scanservjs/"
PKG_UPD="/tmp/scanservjs/"
# Userspace variables
username=scanserv

# Create install/temp folder
if [ -d "$PKG_DIR" ]; then
    echo "Directory found, creating data backup."
    mkdir -p $PKG_UPD
    echo "Backing up configuration and files..."
    cp -a $PKG_DIR/config $PKG_UPD
    cp -a $PKG_DIR/data $PKG_UPD
    if [ -f "/etc/init.d/scanservjs" ]; then
        echo "Stopping service..."
        rc-service scanservjs stop
    fi
    echo "Cleaning up previous install"
    rm -rf $PKG_DIR/*
  else
    echo "No previous scanservjs found in $PKG_DIR, creating install directory"
    mkdir -p $PKG_DIR
fi

# User management
if [ -z "$(grep $username /etc/passwd 2>&1 | tr -s \\n)" ]; then
  # Create the user for running scanservjs and add it to users
  adduser -u 1000 -H -D $username
  adduser $username users
  # Add the new user to the scanner group (created by SANE)
  adduser $username scanner
  # Add the new user to the lp group
  adduser $username lp
fi

# Download and install latest scanservjs release
curl -L $PKG_URL | tar -zxf - -C $PKG_DIR

# Restore data from backup
if [ -d "$PKG_UPD" ]; then
    echo "Restoring config and data from backup..."
    cp -a -v $PKG_UPD/data $PKG_DIR/
    cp -a -v $PKG_UPD/config $PKG_DIR/
fi

# Set permissions
chown -R $username:users $PKG_DIR/config
chown -R $username:users $PKG_DIR/data
chmod +x $PKG_DIR/server/server.js

# Imagemagick edits
# Enable pdf and avoid out of memory issues with large or multiple scans
#  sed -i \
#    's/policy domain="coder" rights="none" pattern="PDF"/policy domain="coder" rights="read | write" pattern="PDF"'/ \
#    /etc/ImageMagick-7/policy.xml
#  sed -i \
#    's/policy domain="resource" name="disk" value="1GiB"/policy domain="resource" name="disk" value="8GiB"'/ \
#    /etc/ImageMagick-7/policy.xml

# Install npm dependencies
npm install -g npm@8.3.0
cd $PKG_DIR && npm install --only=production

# Create service
if [ -f "/etc/init.d/scanservjs" ]; then
      rm -rf /etc/init.d/scanservjs
fi

cat << EOF >> /etc/init.d/scanservjs
#!/sbin/openrc-run

name="scanservjs"
pidfile="/run/${RC_SVCNAME}.pid"
command="/usr/bin/node"
directory="/var/www/scanservjs/"
command_args="./server/server.js"
command_background=true
command_user="$username"

depend() {
    need net
}
EOF
chmod 755 /etc/init.d/scanservjs

# Add service
rc-update add scanservjs default
# Start server
rc-service scanservjs start

# Optional brscan4 driver port install
read -r -p "Want to install the optional brscan4 driver for Brother scanners? <yes/no> " prompt
if [[ $prompt == "YES" || $prompt == "yes" || $prompt == "Yes" ]]
  then
    curl -L https://github.com/x-keita/alpine-scripts/raw/main/install-brscan4.sh | ash --
fi


    cat << EOF

------------------------------------------------------------------------------------
Installed! By default scanservjs runs on port 8080, if you have any issues you can
change the port by editing /var/www/scanservjs/server/config.js @ Line 17

Also, by default files are saved into /var/www/scanservjs/data/output you can change
this by editing /var/www/scanservjs/server/config.js @ Line 47
------------------------------------------------------------------------------------

EOF
