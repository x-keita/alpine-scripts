# Alpine Linux Install Scripts

Scripts for installing stuff on Alpine Linux / Alpine LXC instead of doing it manually because stuff.

## Prerequisites

You need to install bash and curl before running any script. Run the following lines on the terminal

```bash
apk update && apk add install --nocache bash curl
```
## Scripts

Install [scanservjs](https://github.com/sbs20/scanservjs)

```bash
curl -s https://github.com/x-keita/alpine-scripts/raw/main/install-scanservjs.sh | sudo bash -s --
```

