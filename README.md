# Alpine Linux Install Scripts

Scripts for installing stuff on Alpine Linux / Alpine LXC instead of doing it manually because stuff.

## Prerequisites

You need to install bash and curl before running any script. Run the following lines on the terminal

```bash
apk add -U --upgrade --no-cache bash curl
```

## The Arrs!

<details>
  <summary>Sonarr @ https://sonarr.tv</summary>

  #### Details
  - **Installed to**: /opt/sonarr
  - **Upgradeable?**: Yes, using built-in updater
  - **Branch**: You can choose during install and change later on WebUI

  #### Script
```bash
bash <(wget -qO- https://raw.githubusercontent.com/x-keita/alpine-scripts/main/install-sonarr.sh)
```
</details>

<details>
  <summary>Prowlarr @ https://prowlarr.com</summary>

  #### Details
  - **Installed on**: /opt/prowlarr
  - **Upgradeable?**: Yes, using built-in updater
  - **Branch**: Develop (Only branch available)

  #### Script
```bash
bash <(wget -qO- https://raw.githubusercontent.com/x-keita/alpine-scripts/main/install-prowlarr.sh)
```
</details>

<details>
  <summary>Radarr @ https://radarr.video</summary>

  #### Details
  - **Installed on**: /opt/radarr
  - **Upgradeable?**: Yes, using built-in updater
  - **Branch**: You can choose during install and change later on WebUI

  #### Script
```bash
bash <(wget -qO- https://raw.githubusercontent.com/x-keita/alpine-scripts/main/install-radarr.sh)
```
</details>

## Downloaders

<details>
  <summary>qbittorrent-nox (Official Apk) @ https://www.qbittorrent.org/</summary>

  #### Details
  - **UID/GID**: By default qbittorrent creates a user, the scripts adds it to the GID 1000
  - **Upgradeable?**: Yes, from console with apk

  #### Script
```bash
bash <(wget -qO- https://raw.githubusercontent.com/x-keita/alpine-scripts/main/install-qbittorrentnox.sh)
```
</details>

<details>
  <summary>JDownloader2 with No-VNC @ https://jdownloader.org/</summary>

  #### Details
  - **UID/GID**: JDownloader2 will run with UID 1000 by default.
  - **Upgradeable?**: Yes, from application UI & schedule.
  - **Notes**: Runs official JDownloader2 via VNC with noVNC preloaded, you can connect to noVNC in localhost:8080 or VNC in localhost:5900

  #### Script
```bash
bash <(wget -qO- https://raw.githubusercontent.com/x-keita/alpine-scripts/main/install-qbittorrentnox.sh)
```
</details>

## Home Automation

<details>
  <summary>HomeAssistant Core @ https://www.home-assistant.io</summary>

  #### Details
  - **Space required**: At least 3.5 GB for first time install. Post-install storage usage goes down to 1.5~ GB
  - **Upgradeable?**: Yes, run `pip3 install --upgrade homeassistant` to install latest version.

  #### Script
```bash
bash <(wget -qO- https://raw.githubusercontent.com/x-keita/alpine-scripts/main/install-hass.sh)
```
</details>

## Printer & Scanning / Document managers

<details>
  <summary>Scanservjs @ https://github.com/sbs20/scanservjs</summary>

  #### Details
  - **Installed on**: /var/www/scanservjs
  - **Upgradeable?**: Yes, run the script again to install latest version

  #### Script
```bash
bash <(wget -qO- https://github.com/x-keita/alpine-scripts/raw/main/install-scanservjs.sh)
```
</details>

<details>
  <summary>Brother SANE brscan4 driver</summary>

  #### Details
  - **Pre-requisites**: sane-utils and sane-udev

  #### Script
```bash
curl -L https://github.com/x-keita/alpine-scripts/raw/main/install-brscan4.sh | bash --
```
</details>
