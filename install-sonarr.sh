#!/bin/bash

# Bash script for installing sonarr 

# Install required packages and dependencies
apk update && apk add --no-cache \
  curl \
  jq \
  libmediainfo \
  sqlite-libs

# Fetch mono from testing branch
apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  mono

# Create sonarr install folders
mkdir -p /usr/lib/sonarr/bin
mkdir -p /var/lib/sonarr

# Download sonarr
  if [ -z ${SONARR_VERSION+x} ]; then \
    SONARR_VERSION=$(curl -sX GET http://services.sonarr.tv/v1/releases | jq -r ".[] | select(.branch==\"main\") | .version"); \
  fi && \
  curl -o \
    /tmp/sonarr.tar.gz -L \
    "https://download.sonarr.tv/v3/main/${SONARR_VERSION}/Sonarr.main.${SONARR_VERSION}.linux.tar.gz" && \
  tar xzf \
    /tmp/sonarr.tar.gz -C \
    /usr/lib/sonarr/bin --strip-components=1

# Remove integrated update service since we can't use it
rm -rf /usr/lib/sonarr/bin/Sonarr.Update && \

# Post install cleanup
rm -rf /tmp/sonarr.tar.gz

# Create service
curl -L https://raw.githubusercontent.com/x-keita/alpine-scripts/main/init.d/sonarr -o /etc/init.d/sonarr
chmod 755 /etc/init.d/sonarr
# Add service
rc-update add sonarr default
# Start server
rc-service sonarr start

# Set version variables
info="/usr/lib/sonarr/package_info"
cat <<  %%_INFO_%% > $info
PackageVersion=${SONARR_VERSION}
PackageAuthor=[x-keita](https://github.com/x-keita/alpine-scripts)
UpdateMethod=External
UpdateMethodMessage=run 'bash /usr/lib/sonarr/updater.sh' to install latest version
Branch=main
%%_INFO_%%

# Add updater
curl -L https://github.com/x-keita/alpine-scripts/raw/main/updater/sonarr-update.sh -o /usr/lib/sonarr/updater
chmod 755 /usr/lib/sonarr/updater.sh

# Enable update script
sonarr_config="/var/lib/sonarr/config.xml"

if [[ -f "${sonarr_config}" ]]; then
  sed -i 's%<UpdateMechanism>.*</UpdateMechanism>%<UpdateMechanism>Script</UpdateMechanism>%' "${sonarr_config}"
  sed -i 's%<UpdateScriptPath>.*</UpdateScriptPath>%<UpdateScriptPath>/bin/update</UpdateScriptPath>%' "${sonarr_config}"
  if [[ $(grep -c "UpdateScriptPath" "${sonarr_config}") -eq 0 ]]; then
    sed -i 's%\(^</Config>$\)%  <UpdateMechanism>Script</UpdateMechanism>\n  <UpdateScriptPath>/bin/update</UpdateScriptPath>%' "${sonarr_config}"
    echo -n "</Config>" >> "${sonarr_config}"
  fi
else
  {
    echo "<Config>"
    echo "  <LogLevel>info</LogLevel>"
    echo "  <EnableSsl>False</EnableSsl>"
    echo "  <Port>8989</Port>"
    echo "  <SslPort>9898</SslPort>"
    echo "  <BindAddress>*</BindAddress>"
    echo "  <ApiKey>ef8d989bcfce443fae07a408c4700fd1</ApiKey>"
    echo "  <AuthenticationMethod>None</AuthenticationMethod>"
    echo "  <UpdateMechanism>Script</UpdateMechanism>"
    echo "  <UpdateScriptPath>/usr/lib/sonarr/updater</UpdateScriptPath>"
    echo "  <Branch>main</Branch>"
    echo "  <SslCertHash></SslCertHash>"
    echo "</Config>"
  } > "${sonarr_config}"
fi

exit 0
