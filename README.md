# UniFi Protect ARM64

Run UniFi Protect in Docker on ARM64 hardware.

## Usage

Run the container as a daemon:

```bash
docker run -d --name unifi-protect-arm64  \
    --privileged \
    --tmpfs /run \
    --tmpfs /run/lock \
    --tmpfs /tmp \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    -v /storage/srv:/srv \
    -v /storage/data:/data \
    -v /storage/persistent:/persistent \
    --network host \
    markdegroot/unifi-protect-arm64:latest
```

Now you can access UniFi Protect at `https://localhost/`.

## Storage
UniFi Protect needs a lot of storage to record video. Protect will fail to start by default if there is not at least 70GB disk space available, so make sure to store your Docker volumes on a disk with some space (`/storage` in the above run command).

If you are low on space you can change the amount of storage unifi-protect is trying to keep free. Simply go to `/usr/share/unifi-protect/app/config/config.json` inside the container and change the value of`"mbToKeepFree": 1024`. In this example unifi-protect will try to free only 1GB. Now you can run the container even down to 32GB SD-Card.
Keep in mind this change will be lost after recreating the container.

## Stuck at "Device Updating"
If you are stuck at a popup saying "Device Updating" with a blue loading bar after the initial setup, just run `systemctl restart unifi-core` inside the container or restart the entire container. This happens only the first time after the initial setup.

## Build your own container
To build your own container put the deb file for `unifi-core` (for unifi-protect 1.17.3 you need unifi-core 1.6.65) in the `put-unifi-core-deb-here` folder and run:
```bash
docker build -t markdegroot/unifi-protect-arm64 .
```

## Disclaimer
This Docker image is not associated with UniFi in any way. We do not distribute any third party software and only use packages that are freely available on the internet.
