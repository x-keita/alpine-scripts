#!/bin/bash

#
# Bash script for installing brscan4 for Brother scanners
#
install_temp=/tmp/brscan4

# Install required packages and dependencies
apk update && apk add --no-cache \
  dpkg

# Download driver
curl -L https://download.brother.com/welcome/dlf006645/brscan4-0.4.10-1.amd64.deb -o /tmp/brscan4-0.4.10-1.amd64.deb

# Unpackage deb file
dpkg-deb -xv /tmp/brscan4-0.4.10-1.amd64.deb $install_temp

# Copy files from packages
cp -r $install_temp/usr/bin/* /usr/bin
cp -r $install_temp/usr/lib64/* /usr/lib
cp -r $install_temp/opt /
cp -r $install_temp/etc /

# Fix symlinks
cd /usr/lib/sane
ln -sf libsane-brother4.so.1.0.7 libsane-brother4.so.1
ln -sf libsane-brother4.so.1 libsane-brother4.so

# Enable brscan4 for SANE
/opt/brother/scanner/brscan4/setupSaneScan4 -i

# From driver udevconfig.sh - Add rules for Brother scanners
udevrulefile="/usr/lib/udev/rules.d/50-brother-brscan4-libsane-type1.rules"
cat <<  %%_UDEV_RULE_%% > $udevrulefile
#
#   udev rules 
#

ACTION!="add", GOTO="brother_mfp_end"
SUBSYSTEM=="usb", GOTO="brother_mfp_udev_1"
SUBSYSTEM!="usb_device", GOTO="brother_mfp_end"
LABEL="brother_mfp_udev_1"
SYSFS{idVendor}=="04f9", GOTO="brother_mfp_udev_2"
ATTRS{idVendor}=="04f9", GOTO="brother_mfp_udev_2"
GOTO="brother_mfp_end"
LABEL="brother_mfp_udev_2"
ATTRS{bInterfaceClass}!="0ff", GOTO="brother_mfp_end"
ATTRS{bInterfaceSubClass}!="0ff", GOTO="brother_mfp_end"
ATTRS{bInterfaceProtocol}!="0ff", GOTO="brother_mfp_end"
#MODE="0666"
#GROUP="scanner"
ENV{libsane_matched}="yes"
#SYMLINK+="scanner-%k"
LABEL="brother_mfp_end"
%%_UDEV_RULE_%%
####
chmod 755    $udevrulefile

# Cleanup
rm -rf /tmp/brscan4-0.4.10-1.amd64.deb /tmp/brscan4

    cat << EOF

------------------------------------------------------------------------------------
Installed! You can run -> scanimage -L <- and your scanner should appear.

Also if you don't use dpkg you can uninstall it using " apk del dpkg ".
------------------------------------------------------------------------------------

EOF
