FROM raigen/rpi-alpine-python:2.7.13
MAINTAINER Raigen <https://github.com/Raigen>

ARG VCS_REF
ARG BUILD_DATE

ENV CERTBOT_VERSION 0.12.0

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Let's Encrypt / Certbot" \
      org.label-schema.description="Let's Encrypt/Certbot based on hypriot-alpine" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/Raigen/rpi-alpine-certbot"

RUN BUILD_DEPS="py2-pip \
            gcc \
            musl-dev \
            python2-dev \
            libffi-dev \
            openssl-dev" \
    && apk add -U ${BUILD_DEPS} \
        tini \
        dialog \
        libssl1.0 \
    && pip install --no-cache virtualenv \
    && virtualenv --no-site-packages -p python2 /usr/certbot/venv \
    && /usr/certbot/venv/bin/pip install --no-cache-dir certbot==${CERTBOT_VERSION} \
    && pip uninstall --no-cache-dir -y virtualenv \
    && apk del ${BUILD_DEPS} \
    && rm -rf /var/cache/apk/* /root/.cache/pip

EXPOSE 80 443
VOLUME /etc/letsencrypt/

ENTRYPOINT ["/sbin/tini","--","/usr/certbot/venv/bin/certbot"]
CMD ["--help"]
