#!/bin/bash

# Bash script for installing JDownloader2 with noVNC

# Install virtual desktop environment
apk add -U --upgrade --no-cache \
  bash \
  fluxbox \
  xvfb \
  x11vnc
apk add -U --upgrade --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  novnc

# JDownloader2 dependencies
apk add -U --upgrade --no-cache \
  curl \
  openjdk11-jre \
  libstdc++ \
  ttf-dejavu \
  ffmpeg \
  rtmpdump

# Package variables
PKG_DIR="/opt/jdownloader"

# Userspace variables
username=jdownloader
uid=1000

# Create install folder
mkdir -p $PKG_DIR

# User management
adduser -u $uid -H -D $username

# Download latest jdownloader2 installer
curl -L "http://installer.jdownloader.org/JDownloader.jar" -o $PKG_DIR/JDownloader.jar

# Create service
cat << EOF >> /etc/init.d/xvfb
#!/sbin/openrc-run

name="xvfb"
supervisor="supervise-daemon"
pidfile="/run/xvfb.pid"
command="Xvfb"
command_args=":0 -screen 0 "1280"x"768"x24"
command_background=true

depend() {
    need net
}
start_pre() {
  export DISPLAY=:0
}
EOF

cat << EOF >> /etc/init.d/x11vnc
#!/sbin/openrc-run

name="x11vnc"
supervisor="supervise-daemon"
pidfile="/run/x11vnc.pid"
command="/usr/bin/x11vnc"
command_args="-display :0"
command_background=true

depend() {
    need net
}
start_pre() {
  export DISPLAY=:0
}
EOF

cat << EOF >> /etc/init.d/novnc
#!/sbin/openrc-run

name="novnc"
supervisor="supervise-daemon"
pidfile="/run/novnc.pid"
command="/usr/bin/novnc_server"
command_args="--vnc localhost:5900 --listen 8080"
command_background=true

depend() {
    need net
}
start_pre() {
  export DISPLAY=:0
}
EOF

cat << EOF >> /etc/init.d/fluxbox
#!/sbin/openrc-run

name="fluxbox"
supervisor="supervise-daemon"
pidfile="/run/fluxbox.pid"
command="fluxbox"
command_args="-display :0 -no-toolbar"
command_background=true

depend() {
    need net
}
start_pre() {
  export DISPLAY=:0
}
EOF

cat << EOF >> /etc/init.d/jdownloader2
#!/sbin/openrc-run

name="jdownloader2"
supervisor="supervise-daemon"
pidfile="/run/jdownloader2.pid"
command="java"
command_args="-Dawt.useSystemAAFontSettings=gasp -Djava.awt.headless=false -jar /opt/jdownloader/JDownloader.jar"
command_background=true
command_user="$username"

depend() {
    need net
}
start_pre() {
  export DISPLAY=:0
}
EOF

# Set permissions
chown $username:$username -R $PKG_DIR
chmod 755 /etc/init.d/xvfb
chmod 755 /etc/init.d/x11vnc
chmod 755 /etc/init.d/novnc
chmod 755 /etc/init.d/fluxbox
chmod 755 /etc/init.d/jdownloader2

# Execute first run as user
su -c "java -jar /opt/jdownloader/JDownloader.jar -n" $username

# Setup Fluxbox WM
rm -rf /usr/share/fluxbox/init
cat << EOF >> /usr/share/fluxbox/init
! If you're looking for settings to configure, they won't be saved here until
! you change something in the fluxbox configuration menu.

session.menuFile:       ~/.fluxbox/menu
session.keyFile: ~/.fluxbox/keys
session.configVersion:  13
session.screen0.titlebar.left:
session.styleFile:      /usr/share/fluxbox/styles/Meta
EOF

# Start JDownloader maximized
rm -rf /usr/share/fluxbox/apps
cat << EOF >> /usr/share/fluxbox/apps
[app] (name=fbrun)
  [Position]    (WINCENTER)     {0 0}
  [Layer]       {2}
[end]
[app] (name=JDownloader) (class=JDownloader)
  [Maximized]   {yes}
  [Deco]        {TOOL}
[end]
EOF

# JDownloader 2 Patches
# Remove exit button
mkdir -p $PKG_DIR/cfg/menus_v2
curl -L "https://raw.githubusercontent.com/x-keita/alpine-scripts/main/jdownloader2-novnc/MainMenu.menu.json" -o $PKG_DIR/cfg/menus_v2/MainMenu.menu.json
# Disable TrayExtension by default
curl -L "https://raw.githubusercontent.com/x-keita/alpine-scripts/main/jdownloader2-novnc/org.jdownloader.gui.jdtrayicon.TrayExtension.json" -o $PKG_DIR/cfg/org.jdownloader.gui.jdtrayicon.TrayExtension.json
# Fix permissions
chown $username:$username $PKG_DIR/cfg/menus_v2/MainMenu.menu.json
chown $username:$username $PKG_DIR/cfg/org.jdownloader.gui.jdtrayicon.TrayExtension.json


# Add services to start on boot
rc-update add xvfb default
rc-update add x11vnc default
rc-update add novnc default
rc-update add fluxbox default
rc-update add jdownloader2 default

# Start services
rc-service xvfb start
rc-service x11vnc start
rc-service novnc start
rc-service fluxbox start
rc-service jdownloader2 start

    cat << EOF
------------------------------------------------------------------------------------
Installed! JDownloader novnc interface runs on localhost:8080 by default. 
You can change the port by editing /etc/init.d/novnc
------------------------------------------------------------------------------------
EOF
