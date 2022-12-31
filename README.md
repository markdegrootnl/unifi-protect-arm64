# UniFi UNVR with UniFi Protect for ARM64

This image is tested running on a Raspberry Pi 4 8GB model. To run it, use the `docker-compose.yml` below or alternatively run with the `docker run` example below. Persistent storage is under `/storage` and can be any POSIX mountpoint, for example NFS.

**Note: This image does not support migration from UNVR 2.x.**

## Docker run example

```
docker run -d --name unifi-unvr  \
    --privileged \
    --tmpfs /run \
    --tmpfs /run/lock \
    --tmpfs /tmp \
    -v '/var/run/dbus:/var/run/dbus' \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    -v /storage/srv:/srv \
    -v /storage/data:/data \
    -v /storage/persistent:/persistent \
    --network host \
    snowsnoot/unifi-unvr:latest
```

## Docker compose example

```
version: '3'
services:
  unifi-protect:
    container_name: unifi-unvr
    privileged: true
    tmpfs:
      - '/run'
      - '/run/lock'
      - '/tmp'
    volumes:
      - '/var/run/dbus:/var/run/dbus'
      - '/sys/fs/cgroup:/sys/fs/cgroup:ro'
      - '/storage/srv:/srv'
      - '/storage/data:/data'
      - '/storage/persistent:/persistent'
    network_mode: 'host'
    restart: unless-stopped
    image: 'snowsnoot/unifi-unvr:latest'
```

## Systemd unit file example

This systemd unit file assumes the above `docker-compose.yml` is placed in `/root/docker/compose`. Install it in `/etc/systemd/system/unifi-unvr.service` and then run `systemctl daemon-reload` and `systemctl enable unifi-unvr`

```
[Unit]
Description=Unifi UNVR
Requires=docker.service
After=docker.service
RequiresMountsFor=/storage

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/root/docker/compose
ExecStart=/usr/bin/docker compose -f docker-compose.yml up -d --remove-orphans
ExecStop=/usr/bin/docker compose -f docker-compose.yml down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

## Issues with remote access

There is a known issue that remote access to your UNVR (via the Ubnt cloud) will not work with the console unless the primary network interface is named `enp0s2`. To achieve this on a Raspberry Pi 4, create the `/etc/systemd/network/99-enp0s2.link` file with the below content, replacing `xx:xx:xx:xx:xx:xx` with your actual MAC address, and then reboot.

```
[Match]
MACAddress=xx:xx:xx:xx:xx:xx

[Link]
Name=enp0s2

[Network]
DHCP=yes
```

## Build Instructions

The image can be build from the GitHub repo https://github.com/snowsnoot/unifi-unvr-arm64

```
git clone https://github.com/snowsnoot/unifi-unvr-arm64
cd unifi-unvr-arm64
scripts/fwextract.sh {unvr_firmware_download_url}
docker build -t {tag_name} .
```

Disclaimer: This creators of this repo and associated container images are not affiliated with Ubiquiti Networks in any way and no license or warranty is provided or implied. This repo only uses data and files that can be freely found on the internet. Use at your own risk.

Credits: This repo and container image is a fork of https://github.com/markdegrootnl/unifi-protect-arm64

