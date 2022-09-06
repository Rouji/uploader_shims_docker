FROM alpine:3.16 AS builder

RUN apk add git g++ meson ninja libssh-dev curl-dev \
 && git clone -b master --single-branch https://github.com/Rouji/nc2p.git /opt/nc2p \
 && cd /opt/nc2p && meson build && ninja -C build \
 && git clone -b master --single-branch https://github.com/Rouji/ssh2p.git /opt/ssh2p \
 && cd /opt/ssh2p && meson build && ninja -C build

FROM alpine:3.16

COPY entry.sh /entry.sh
COPY supervisord.conf /etc/supervisord.conf
COPY --from=builder /opt/nc2p/build/nc2p /usr/bin/
COPY --from=builder /opt/ssh2p/build/ssh2p /usr/bin/
RUN apk --no-cache add supervisor libssh libcurl openssh-keygen \
 && mkdir /rsa \
 && chmod u+x /entry.sh


VOLUME /rsa
EXPOSE 9999
EXPOSE 22

ENTRYPOINT ["/entry.sh"]
