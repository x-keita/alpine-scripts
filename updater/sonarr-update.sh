# Sonarr update script for Alpine Linux

SONARR_VERSION=$(curl -sX GET http://services.sonarr.tv/v1/releases | jq -r ".[] | select(.branch==\"main\") | .version")
CURRENT_VERSION=$(cat /usr/lib/sonarr/package_info | grep PackageVersion | tr -d 'PackageVersion=')

if [ "${CURRENT_VERSION}" = "${SONARR_VERSION}" ]; then
    echo "Packages are the same version, no need to update."
    exit 1
else
    echo "Updating from ${CURRENT_VERSION} to ${SONARR_VERSION}"
    # Remove previous verssion
    rm -rf /usr/lib/sonarr/bin/*
    
    # Download latest package
    curl -o \
      /tmp/sonarr.tar.gz -L \
      "https://download.sonarr.tv/v3/main/${SONARR_VERSION}/Sonarr.main.${SONARR_VERSION}.linux.tar.gz" && \
    tar xzf \
      /tmp/sonarr.tar.gz -C \
      /usr/lib/sonarr/bin --strip-components=1

    # Remove integrated update service since we can't use it
    rm -rf /usr/lib/sonarr/bin/Sonarr.Update

    # Post update cleanup
    rm -rf /tmp/sonarr.tar.gz

    # Recreate package_info with updated PackageVersion
    rm -rf /usr/lib/sonarr/package_info

updated_info="/usr/lib/sonarr/package_info"
cat <<  %%_UPDATED_INFO_%% > $updated_info
PackageVersion=${SONARR_VERSION}
PackageAuthor=[x-keita](https://github.com/x-keita/alpine-scripts)
UpdateMethod=External
Branch=main
%%_UPDATED_INFO_%%

fi
exit 0
