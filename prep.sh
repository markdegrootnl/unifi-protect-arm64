#!/bin/bash
# This creates a folder structure to avoid any permission issues which I noticed. Unifi Protect fails to start because of failing to create some folders
mkdir -p unifi-protect/data/{unifi-core,ulp-go}
mkdir -p unifi-protect/srv/unifi-protect
mkdir -p unifi-protect/storage/persistent
mkdir 777 unifi-protect/ -R
