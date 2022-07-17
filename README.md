# Alpine Linux Install Scripts

Scripts for installing stuff on Alpine Linux / Alpine LXC instead of doing it manually because stuff.

## Prerequisites

You need to install bash and curl before running any script. Run the following lines on the terminal

```bash
apk update && apk add --no-cache bash curl
```

## The Arrs!

<details>
  <summary>Sonarr @ https://sonarr.tv</summary>

  #### Details
  - **Installed to**: /usr/lib/sonarr
  - **Upgradeable?**: Yes, using built-in updater
  - **Branch**: Main (Can change on GUI)

  #### Script
```bash
curl -L https://github.com/x-keita/alpine-scripts/raw/main/install-sonarr.sh | bash --
```
</details>

<details>
  <summary>Prowlarr @ https://prowlarr.com</summary>

  #### Details
  - **Installed on**: /usr/lib/prowlarr
  - **Upgradeable?**: Yes, using built-in updater
  - **Branch**: Develop (Only branch available)

  #### Script
```bash
curl -L https://github.com/x-keita/alpine-scripts/raw/main/install-prowlarr.sh | bash --
```
</details>

<details>
  <summary>Radarr @ https://radarr.video</summary>

  #### Details
  - **Installed on**: /usr/lib/radarr
  - **Upgradeable?**: Yes, using built-in updater
  - **Branch**: Master (Can change on GUI)

  #### Script
```bash
curl -L https://github.com/x-keita/alpine-scripts/raw/main/install-radarr.sh | bash --
```
</details>

## Home Automation

<details>
  <summary>HomeAssistant Core @ https://www.home-assistant.io</summary>

  #### Details
  - **Space required**: At least 3.5 GB for first time install. Post-install storage usage goes down to 1.5~ GB
  - **Upgradeable?**: Yes, run `pip3 install --upgrade homeassistant` to install latest version
  - **Bugs**: On System Health, `Installation Type` appears as `Unknown`

  #### Script
```bash
curl -L https://github.com/x-keita/alpine-scripts/raw/main/install-hass.sh | bash --
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
ash <(wget -qO- https://github.com/x-keita/alpine-scripts/raw/main/install-scanservjs.sh)
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
