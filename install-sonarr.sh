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
echo "UpdateMethod=External\nBranch=main\nPackageVersion=${SONARR_VERSION}\nPackageAuthor=[x-keita](https://github.com/x-keita/alpine-scripts)" > /usr/lib/sonarr/package_info

# Add updater
updater="/usr/lib/sonarr/updater.sh"
cat <<  %%_UPDATER_%% > $updater
#!/bin/bash

# Sonarr update script for Alpine Linux

SONARR_VERSION=$(curl -sX GET http://services.sonarr.tv/v1/releases | jq -r ".[] | select(.branch==\"main\") | .version")
CURRENT_VERSION=$(cat /usr/lib/sonarr/package_info | grep PackageVersion | tr -d 'PackageVersion=')

if [ "$CURRENT_VERSION" = "$SONARR_VERSION ]; then
    echo "Packages are the same version, no need to update."
    exit 1
else
    # Download latest package
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

# Recreate package_info with updated PackageVersion
rm -rf /usr/lib/sonarr/package_info
echo "UpdateMethod=External\nBranch=main\nPackageVersion=${SONARR_VERSION}\nPackageAuthor=[x-keita](https://github.com/x-keita/alpine-scripts)" > /usr/lib/sonarr/package_info
fi
exit 0
%%_UPDATER_%%
####
chmod 755 $updater
