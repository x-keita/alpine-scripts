#!/bin/bash

# Bash script for installing brscan4 for Brother scanners

# Install required packages and dependencies
apk update && apk add --no-cache \
  dpkg \
  eudev

# Temporarily add amd64 as a supported arch
sudo dpkg --add-architecture amd64

# Download driver
curl -L https://github.com/x-keita/alpine-scripts/raw/main/drivers/scanner/brscan4-0.4.10-1.amd64.deb -o /tmp/brscan4-0.4.10-1.amd64.deb

# Install driver
dpkg -i /tmp/brscan4-0.4.10-1.amd64.deb

# Remove amd64
sudo dpkg --remove-architecture amd64

echo "--------------------------------------------------------------------"
echo "You probably saw some errors but it's probably fine, probably."
echo "You can run -> scanimage -L <- and your scanner should appear!"
echo "If you don't need dpkg you can uninstall it using -> apk del dpkg <-"
echo "--------------------------------------------------------------------"

# Cleanup
rm -rf /tmp/brscan4-0.4.10-1.amd64.deb

exit 0
