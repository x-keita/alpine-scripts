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
curl -L https://github.com/x-keita/alpine-scripts/raw/main/install-scanservjs.sh -o /tmp/install-scanservjs.sh && bash /tmp/install-scanservjs.sh & rm -rf bash /tmp/install-scanservjs.sh
```

## Drivers

Install Brother brscan4 scanner driver for SANE (Requires to have sane-utils already installed!)

```bash
curl -L https://raw.githubusercontent.com/x-keita/alpine-scripts/main/install-brscan4.sh -o /tmp/install-brscan4.sh && bash /tmp/install-brscan4.sh & rm -rf bash /tmp/install-brscan4.sh
```


