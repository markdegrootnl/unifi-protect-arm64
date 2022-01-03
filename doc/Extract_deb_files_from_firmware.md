```bash
#!/bin/bash
set -e

sudo apt-get update \
    && sudo apt-get -y install binwalk dpkg-repack dpkg

wget -O fwupdate.bin <URL_OF_THE_UNVR_FIRMWARE.BIN>
sudo binwalk -e fwupdate.bin

dpkg-query --admindir=_fwupdate.bin.extracted/squashfs-root/var/lib/dpkg/ -W -f='${package} | ${Maintainer}\n' | grep -E "@ubnt.com|@ui.com" | cut -d "|" -f 1 > packages.txt

while read pkg; do
  dpkg-repack --root=_fwupdate.bin.extracted/squashfs-root/ --arch=arm64 ${pkg}
done < packages.txt
```
