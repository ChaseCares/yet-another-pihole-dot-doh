ARG TAG='latest'
FROM ghcr.io/pi-hole/pihole:${TAG}

ARG TARGETARCH

ADD https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${TARGETARCH}.deb /tmp/cloudflared-linux-${TARGETARCH}.deb

RUN apt-get update && apt-get install -y stubby && \
    dpkg --add-architecture ${TARGETARCH} && \
    apt-get install /tmp/cloudflared-linux-${TARGETARCH}.deb && \
    useradd -s /usr/sbin/nologin -r -M cloudflared && \
    chown cloudflared:cloudflared /usr/local/bin/cloudflared && \
    apt-get -y autoremove && \
    apt-get -y autoclean && \
    apt-get -y clean && \
    rm -fr /tmp/* /var/tmp/* /var/lib/apt/lists/* /etc/stubby

COPY ./s6/debian-root /
COPY ./config /tmp/config

VOLUME ["/config"]
