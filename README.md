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

## Running ARM64 on x86 machines
Thanks to Docker, we can now run ARM64 on x86 machines. You can read more about that [here](https://docs.docker.com/build/building/multi-platform/)

As you can see the container says `aarch64` while my host says `x86_64`:
```
[user@zou:~/unifi-protect-arm64]$ docker exec -it unifi-protect /bin/bash
root@bam:/# uname -a
Linux bam 5.15.113 #1-NixOS SMP Wed May 24 16:36:55 UTC 2023 aarch64 GNU/Linux
root@bam:/# 
exit

[user@zou:~/unifi-protect-arm64]$ uname -a
Linux zou 5.15.113 #1-NixOS SMP Wed May 24 16:36:55 UTC 2023 x86_64 GNU/Linux
```

In a nutshell:
  * Enable ARM64 on your machine: 
```
docker run --privileged --rm tonistiigi/binfmt --install all
```
Note: It seems the changes are temporary and I always have to execute this command after reboot. 

  * Set `systemd.unified_cgroup_hierarchy=0` as kernel boot param and reboot. You can check if worked by `cat /proc/cmdline`, it should show up there.
  * `docker-compose up -d`
  * Wait, about 2 to 5 minutes and then you should be able to connect to https://localhost and configure it

Debugging:
```
docker-compose exec  unifi-protect /bin/bash
journactl -xf
systemctl status unifi-core
systemctl status unifi-protect
```

Logs can be found at this location:
```
# Inside container:
/data/ulp-go/log/ 
/data/unifi-core/logs/
# Same, just host level:
unifi-protect/data/ulp-go/log
unifi-protect/data/unifi-core/logs
```

TODO: 
 * Redirect systemd logs to docker-compose logs
 * Figure out a way to run without `privileged=true` 
 * Make arm64 persistent without running the command all the time after boot
 * Build using github actions ?
## Storage
UniFi Protect needs a lot of storage to record video. Protect will fail to start if there is not at least 100GB disk space available, so make sure to store your Docker volumes on a disk with some space (`/storage` in the above run command).

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
