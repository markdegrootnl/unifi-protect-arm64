FROM arm64v8/debian:9

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
    && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
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

RUN apt-get update \
    && apt-get -y --no-install-recommends install postgresql \
    && sed -i 's/peer/trust/g' /etc/postgresql/9.6/main/pg_hba.conf \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y dirmngr

COPY put-unifi-core-deb-here/*.deb files/ /

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv 379CE192D401AB61 \
    && apt-get update \
    && apt-get -y --no-install-recommends install /*.deb unifi-protect \
    && rm -f /*.deb \
    && rm -rf /var/lib/apt/lists/* \
    && /usr/local/sbin/postgresql.sh \
    && rm /usr/local/sbin/postgresql.sh \
    && echo "exit 0" > /usr/sbin/policy-rc.d \
    && sed -i "s/Requires=network.target postgresql-cluster@9.6-main.service ulp-go.service/Requires=network.target postgresql-cluster@9.6-main.service/" /lib/systemd/system/unifi-core.service \
    && sed -i 's/redirectHostname: unifi//' /usr/share/unifi-core/app/config/config.yaml

VOLUME ["/srv", "/data"]

CMD ["/lib/systemd/systemd"]
