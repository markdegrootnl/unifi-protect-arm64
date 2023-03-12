# UniFi Protect ARM64

Run UniFi Protect in Docker on ARM64 hardware.

## Usage

Run the container as a daemon:

```bash
docker run -d --name unifi-protect  \
    --privileged \
    --tmpfs /run \
    --tmpfs /run/lock \
    --tmpfs /tmp \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    -v /storage/srv:/srv \
    -v /storage/data:/data \
    -v /storage/persistent:/persistent \
    --network host \
    -e STORAGE_DISK=/dev/sda1 \
    markdegroot/unifi-protect-arm64
```

Now you can access UniFi Protect at `https://localhost/`.

## Storage
UniFi Protect needs a lot of storage to record video. Protect will fail to start by default if there is not at least 70GB disk space available, so make sure to store your Docker volumes on a disk with some space (`/storage` in the above run command).

If you are low on space you can change the amount of storage unifi-protect is trying to keep free. Simply go to `/usr/share/unifi-protect/app/config/config.json` inside the container and change the value of`"mbToKeepFree": 1024`. In this example unifi-protect will try to free only 1GB. Now you can run the container even down to 32GB SD-Card.
Keep in mind this change will be lost after recreating the container.

Optional: Update the env variable `STORAGE_DISK` to your disk to see disk usage inside UniFi Protect.

## Stuck at "Device Updating"
If you are stuck at a popup saying "Device Updating" with a blue loading bar after the initial setup, just run `systemctl restart unifi-core` inside the container or restart the entire container. This happens only the first time after the initial setup.

## Build your own image
To build your own image download and [extract the UNVR firmware](doc/Extract_deb_files_from_firmware.md) and place the needed files in [`put-deb-files-here`](put-deb-files-here/README.md) and [`put-version-file-here`](put-version-file-here/README.md).

Build the image using:
```bash
docker build -t markdegroot/unifi-protect-arm64 .
```
## Issues with remote access
There is a known issue that remote access to your UNVR (via the Ubnt cloud) will not work with the console unless the primary network interface is named `enp0s2`. To achieve this, **on your host machine** create the file `/etc/systemd/network/98-enp0s2.link` with the content below, replacing `xx:xx:xx:xx:xx:xx` with your actual MAC address.
```
[Match]
MACAddress=xx:xx:xx:xx:xx:xx

[Link]
Name=enp0s2
```
Make sure to update your network settings to reflect the new interface name. To apply the settings, run `sudo update-initramfs -u` and reboot your host machine.

Thanks: https://github.com/snowsnoot/unifi-unvr-arm64#issues-with-remote-access

## Issues running Systemd inside Docker
If you're getting the following error (or any systemd error):
```
Failed to create /init.scope control group: Read-only file system
Failed to allocate manager object: Read-only file system
[!!!!!!] Failed to allocate manager object.
Exiting PID 1...
```
Boot the system with kernel parameter `systemd.unified_cgroup_hierarchy=0`

See: https://github.com/moby/moby/issues/42275

## Disclaimer
This Docker image is not associated with UniFi in any way. We do not distribute any third party software and only use packages that are freely available on the internet.
