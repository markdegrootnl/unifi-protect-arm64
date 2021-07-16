#!/bin/bash

cp /sbin/pg-cluster-setup /usr/local/sbin/pg-csetup
chmod +x /usr/local/sbin/pg-csetup

sed -i 's/systemctl/#systemctl/g' /usr/local/sbin/pg-csetup
sed -i 's/pg_createcluster ${CCARGS} | ${INFO_LOGGER}/pg_createcluster ${CCARGS}/g' /usr/local/sbin/pg-csetup
sed -i 's/logger -s -p daemon.* -t ${progname} -i/echo/g' /usr/local/sbin/pg-csetup

for f in /etc/default/postgresql/*; do
	source $f
	set -a && . "$f" && /usr/local/sbin/pg-csetup
done

rm -f /usr/local/sbin/pg-csetup
