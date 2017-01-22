FROM endial/base-alpine

MAINTAINER Endial Fang ( endial@126.com )

# install openssl
RUN apk update \
  && apk add openssl \
  && rm -rf /var/cache/apk/*

# certificate directories
ENV CERT_DIR "/srv/cert"
VOLUME ["$CERT_DIR"]

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD []
