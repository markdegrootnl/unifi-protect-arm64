#!/bin/bash
set -e

firmware_dir=./firmware
firmware_filename=firmware.bin

if [[ $# -ne 1 ]]; then
  echo "ERROR: Incorrect number of arguments"
  echo "Usage: $0 {firmware_url}"
  exit 1
fi

sudo apt-get update
sudo apt-get -y install curl binwalk dpkg-repack dpkg

rm -rf ${firmware_dir}
mkdir -p ${firmware_dir}
cd ${firmware_dir}

curl -o ${firmware_filename} $1
sudo binwalk -e ${firmware_filename}

dpkg-query --admindir=_${firmware_filename}.extracted/squashfs-root/var/lib/dpkg/ -W -f='${package} | ${Maintainer}\n' | grep -E "@ubnt.com|@ui.com" | cut -d "|" -f 1 > packages.txt

while read pkg; do
  dpkg-repack --root=_${firmware_filename}.extracted/squashfs-root/ --arch=arm64 ${pkg}
done < packages.txt

cp -p _${firmware_filename}.extracted/squashfs-root/usr/lib/version ./version

# Remove unused packages
rm ble-http-transport*.deb \
   kmod*.deb \
   linux-image*.deb \
   ubnt-rpsd*.deb \
   ustd*.deb

# Remove unused firmware files
rm -rf _${firmware_filename}.extracted
rm ${firmware_filename}

