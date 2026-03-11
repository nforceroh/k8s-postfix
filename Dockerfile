FROM ghcr.io/nforceroh/k8s-alpine-baseimage:3.23

ARG \
  BUILD_DATE=unknown \
  VERSION=unknown

LABEL \
  org.label-schema.maintainer="Sylvain Martin (sylvain@nforcer.com)" \
  org.label-schema.build-date="${BUILD_DATE}" \
  org.label-schema.version="${VERSION}" \
  org.label-schema.vcs-url="https://github.com/nforcer/k8s-postfix" \
  org.label-schema.schema-version="1.0"

ENV MAILNAME=mail.example.com \
    MYNETWORKS=127.0.0.0/8\ 10.0.0.0/8\ 172.16.0.0/12\ 192.168.0.0/16 \
    DB_HOST=10.0.0.101 \
    DB_USER=root \
    DB_PASSWORD=CHANGE_THIS_PASSWORD \
    DB_DATABASE=mail \
    DOVECOT_HOST=10.0.0.101 \
    DOVECOT_LMTP=24 \
    DOVECOT_SASL=12345 \
    RSPAMD_HOST=10.0.0.101 \
    RSPAMD_PORT=11334 \
    RSPAMD_ENABLE=false \
    SSL_CERT=/etc/postfix/certs/tls.crt \
    SSL_KEY=/etc/postfix/certs/tls.key \
    WAITSTART_TIMEOUT=1m \
    RELAYHOST="mail.twc.com"

RUN echo "Installing postfix" \
  && apk -u add --no-cache postfix postfix-mysql postfix-pcre mailx policyd-spf-fs postfix-doc mariadb-client rspamd-client opendkim gettext \
    && update-ca-certificates  \
    && rm -rf /var/cache/apk/* /usr/src/* 

COPY /content/etc/postfix /etc/postfix
COPY --chmod=755 /content/etc/s6-overlay /etc/s6-overlay

#Exposing tcp ports
EXPOSE 25 465 587

#Adding volumes
VOLUME ["/var/spool/postfix"]
ENTRYPOINT ["/init"]