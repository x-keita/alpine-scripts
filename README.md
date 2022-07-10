# Alpine Linux Install Scripts

Scripts for installing stuff on Alpine Linux / Alpine LXC instead of doing it manually because stuff.

## Prerequisites

You need to install bash and curl before running any script. Run the following lines on the terminal

```bash
apk update && apk add --no-cache bash curl
```
## Applications

Install [scanservjs](https://github.com/sbs20/scanservjs)

```bash
curl -L https://github.com/x-keita/alpine-scripts/raw/main/install-scanservjs.sh | bash --
```

Install [Sonarr](https://sonarr.tv) @ main branch

```bash
curl -L https://github.com/x-keita/alpine-scripts/raw/main/install-sonarr.sh | bash --
```

Install [Prowlarr](https://prowlarr.com/) @ develop branch

```bash
curl -L https://github.com/x-keita/alpine-scripts/raw/main/install-prowlarr.sh | bash --
```

Install [Radarr](https://radarr.video/) @ master branch

```bash
curl -L https://github.com/x-keita/alpine-scripts/raw/main/install-radarr.sh | bash --
```

Install [HomeAssistant Core](https://www.home-assistant.io/) 

```bash
curl -L https://github.com/x-keita/alpine-scripts/raw/main/install-hass.sh | bash --
```

## Drivers

Install Brother brscan4 sane scanner driver (Requires to have sane-utils and sane-udev already installed!)

```bash
curl -L https://github.com/x-keita/alpine-scripts/raw/main/install-brscan4.sh | bash --
```
