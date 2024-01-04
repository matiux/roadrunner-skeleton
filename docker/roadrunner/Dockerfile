ARG RR_VERSION
ARG RR_IMAGE=spiralscout/roadrunner:${RR_VERSION}
ARG PHP_IMAGE=php:${PHP_IMAGE}

FROM ${RR_IMAGE} as rr
FROM ${PHP_IMAGE}

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    net-tools \
    protobuf-compiler \
    && docker-php-ext-install \
    sockets \
    && apt-get remove --purge -y software-properties-common \
    && apt-get autoremove -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./conf/xdebug-starter.sh /usr/local/bin/xdebug-starter
RUN chmod +x /usr/local/bin/xdebug-starter
RUN /usr/local/bin/xdebug-starter

USER utente

# Copy RoadRunner
COPY --from=rr /usr/bin/rr /usr/bin/rr

# Copy RoadRunner config
COPY --from=rr /etc/rr.yaml /etc/rr.yaml

USER root

CMD ["/usr/bin/rr", "serve", "-p", "-c", "/etc/rr.yaml"]