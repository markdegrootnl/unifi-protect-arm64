FROM arm64v8/debian:11

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get -y install curl gnupg apt-transport-https ca-certificates pcregrep iproute2

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -

RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null \
 && echo "deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main" > /etc/apt/sources.list.d/postgresql.list

RUN apt-get -y install systemd

COPY firmware/*.deb /var/tmp/
COPY firmware/_firmware.bin.extracted/squashfs-root/usr/lib/version /usr/lib/version

RUN apt-get -y install /var/tmp/ubnt-archive-keyring_*_arm64.deb

RUN echo 'deb https://apt.artifacts.ui.com bullseye main release beta' > /etc/apt/sources.list.d/ubiquiti.list \
 && chmod 666 /etc/apt/sources.list.d/ubiquiti.list

RUN apt-get update
RUN apt-get -y -o Dpkg::Options::="--force-overwrite" -o Dpkg::Options::="--force-confnew" install /var/tmp/*.deb

RUN rm -f /var/tmp/*.deb \
 && sed -i 's/redirectHostname: unifi//' /usr/share/unifi-core/app/config/config.yaml \
 && sed -i "s|data_directory = '/var/lib/postgresql/14/main'|data_directory = '/data/postgresql/14/main/data'|g" /etc/postgresql/14/main/postgresql.conf \
 && rm -rf /lib/systemd/system/postgresql-cluster@9.6-protect.service.d \
           /lib/systemd/system/postgresql-cluster-14-main-upgrade.service \
           /lib/systemd/system/postgresql-cluster-14-protect-cleanup.service \
           /lib/systemd/system/postgresql-cluster-14-protect-migrate.service \
           /lib/systemd/system/postgresql-cluster-14-protect-upgrade.service \
           /lib/systemd/system/postgresql-cluster\@14-main.service.d \
           /lib/systemd/system/postgresql-cluster\@14-protect.service.d

RUN pg_dropcluster --stop 9.6 main

COPY static_files/etc /etc/
COPY static_files/usr /usr/
COPY static_files/sbin /sbin/

VOLUME ["/srv", "/data", "/persistent"]

CMD ["/lib/systemd/systemd"]

