FROM arm64v8/debian:11

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y --no-install-recommends install \
        curl \
        wget \
        mount \
        psmisc \
        dpkg \
        apt \
        lsb-release \
        sudo \
        gnupg \
        apt-transport-https \
        ca-certificates \
        dirmngr \
        mdadm \
        iproute2 \
        ethtool \
        procps \
        systemd-timesyncd \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get -y --no-install-recommends install systemd \
    && find /etc/systemd/system \
        /lib/systemd/system \
        -path '*.wants/*' \
        -not -name '*journald*' \
        -not -name '*systemd-tmpfiles*' \
        -not -name '*systemd-user-sessions*' \
        -exec rm \{} \; \
    && rm -rf /var/lib/apt/lists/*
STOPSIGNAL SIGKILL

RUN curl -sL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main" > /etc/apt/sources.list.d/postgresql.list \
    && apt-get update \
    && apt-get -y --no-install-recommends install postgresql-14 postgresql-9.6 \
    && rm -rf /var/lib/apt/lists/*

COPY put-deb-files-here/*.deb /
COPY put-version-file-here/version /usr/lib/version
COPY files/lib /lib/

RUN apt-get -y --no-install-recommends install /ubnt-archive-keyring_*_arm64.deb \
    && echo 'deb https://apt.artifacts.ui.com bullseye main release beta' > /etc/apt/sources.list.d/ubiquiti.list \
    && chmod 666 /etc/apt/sources.list.d/ubiquiti.list \
    && apt-get update \
    && apt-get -y --no-install-recommends install /*.deb unifi-protect \
    && rm -f /*.deb \
    && rm -rf /var/lib/apt/lists/* \
    && echo "exit 0" > /usr/sbin/policy-rc.d \
    && sed -i 's/redirectHostname: unifi//' /usr/share/unifi-core/app/config/config.yaml \
    && mv /sbin/mdadm /sbin/mdadm.orig \
    && mv /usr/sbin/smartctl /usr/sbin/smartctl.orig \
    && systemctl enable storage_disk dbpermissions\
    && pg_dropcluster --stop 9.6 main \
    && sed -i 's/rm -f/rm -rf/' /sbin/pg-cluster-upgrade \
    && sed -i 's/OLD_DB_CONFDIR=.*/OLD_DB_CONFDIR=\/etc\/postgresql\/9.6\/main/' /sbin/pg-cluster-upgrade

COPY files/sbin /sbin/
COPY files/usr /usr/
COPY files/etc /etc/

VOLUME ["/srv", "/data", "/persistent"]

CMD ["/lib/systemd/systemd"]
